<?php

namespace App\Jobs;

use App\Models\Review;
use App\Models\Salon;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ImportGoogleReviewsJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        protected Salon $salon,
        protected string $googlePlaceId
    ) {}

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $apiKey = config('services.google.places_api_key');
        
        if (!$apiKey) {
            Log::warning('Google Places API key not configured');
            return;
        }

        try {
            // Fetch place details including reviews
            $response = Http::get('https://maps.googleapis.com/maps/api/place/details/json', [
                'place_id' => $this->googlePlaceId,
                'fields' => 'reviews,rating,user_ratings_total',
                'key' => $apiKey,
                'language' => 'de', // German reviews
            ]);

            if (!$response->successful()) {
                Log::error('Failed to fetch Google reviews', [
                    'salon_id' => $this->salon->id,
                    'place_id' => $this->googlePlaceId,
                    'status' => $response->status(),
                ]);
                return;
            }

            $data = $response->json();
            
            if (!isset($data['result']['reviews'])) {
                Log::info('No Google reviews found', [
                    'salon_id' => $this->salon->id,
                    'place_id' => $this->googlePlaceId,
                ]);
                return;
            }

            $googleReviews = $data['result']['reviews'];
            
            foreach ($googleReviews as $googleReview) {
                // Check if review already exists
                $existingReview = Review::where('salon_id', $this->salon->id)
                    ->where('source', 'google')
                    ->where('source_id', $googleReview['author_url'] ?? $googleReview['time'])
                    ->first();

                if ($existingReview) {
                    // Update existing review if rating or text changed
                    if ($existingReview->rating != $googleReview['rating'] || 
                        $existingReview->body != ($googleReview['text'] ?? null)) {
                        $existingReview->update([
                            'rating' => $googleReview['rating'],
                            'body' => $googleReview['text'] ?? null,
                            'author_name' => $googleReview['author_name'],
                        ]);
                    }
                } else {
                    // Create new review
                    Review::create([
                        'salon_id' => $this->salon->id,
                        'user_id' => null, // Google reviews have no local user
                        'rating' => $googleReview['rating'],
                        'body' => $googleReview['text'] ?? null,
                        'source' => 'google',
                        'source_id' => $googleReview['author_url'] ?? $googleReview['time'],
                        'author_name' => $googleReview['author_name'],
                        'approved' => true, // Auto-approve Google reviews
                        'created_at' => \Carbon\Carbon::createFromTimestamp($googleReview['time']),
                        'updated_at' => \Carbon\Carbon::createFromTimestamp($googleReview['time']),
                    ]);
                }
            }

            // Update salon metadata
            $this->salon->update([
                'google_place_id' => $this->googlePlaceId,
                'google_rating' => $data['result']['rating'] ?? null,
                'google_ratings_total' => $data['result']['user_ratings_total'] ?? 0,
                'google_reviews_imported_at' => now(),
            ]);

            Log::info('Successfully imported Google reviews', [
                'salon_id' => $this->salon->id,
                'count' => count($googleReviews),
            ]);

        } catch (\Exception $e) {
            Log::error('Error importing Google reviews', [
                'salon_id' => $this->salon->id,
                'place_id' => $this->googlePlaceId,
                'error' => $e->getMessage(),
            ]);
            throw $e;
        }
    }
}