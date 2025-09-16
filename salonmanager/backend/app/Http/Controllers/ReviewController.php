<?php

namespace App\Http\Controllers;

use App\Http\Requests\Review\StoreReviewRequest;
use App\Http\Requests\Review\UpdateReviewRequest;
use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    /**
     * Display a listing of the reviews.
     */
    public function index(Request $request): JsonResponse
    {
        $salon = app('tenant');
        
        $query = Review::where('salon_id', $salon->id)
            ->where('approved', true)
            ->with(['user:id,name,email'])
            ->orderByDesc('created_at');

        // Optional filtering by source
        if ($request->has('source')) {
            $query->where('source', $request->get('source'));
        }

        // Optional filtering by rating
        if ($request->has('rating')) {
            $query->where('rating', $request->get('rating'));
        }

        $reviews = $query->paginate($this->perPage($request, 20, 50));

        return response()->json([
            'items' => $reviews,
            'summary' => [
                'average_rating' => $salon->avgRating(),
                'total_reviews' => $salon->reviewCount(),
                'rating_distribution' => $this->getRatingDistribution($salon->id)
            ]
        ]);
    }

    /**
     * Store a newly created review.
     */
    public function store(StoreReviewRequest $request): JsonResponse
    {
        $salonId = app('tenant')->id;
        $validated = $request->validated();

        // Check if user has already reviewed this salon
        $existingReview = Review::where('salon_id', $salonId)
            ->where('user_id', $request->user()->id)
            ->where('source', 'local')
            ->first();

        if ($existingReview) {
            return response()->json([
                'message' => 'Sie haben diesen Salon bereits bewertet.',
                'review' => $existingReview
            ], 422);
        }

        $review = Review::create([
            'salon_id' => $salonId,
            'user_id' => $request->user()->id,
            'rating' => $validated['rating'],
            'body' => $validated['body'] ?? null,
            'media_ids' => $validated['media_ids'] ?? [],
            'source' => 'local',
            'author_name' => $request->user()->name,
            'approved' => true, // Auto-approve for now, can be changed to moderation workflow
        ]);

        $review->load('user:id,name,email');

        return response()->json([
            'message' => 'Vielen Dank für Ihre Bewertung!',
            'review' => $review
        ], 201);
    }

    /**
     * Display the specified review.
     */
    public function show(Review $review): JsonResponse
    {
        // Ensure review belongs to current salon
        if ($review->salon_id !== app('tenant')->id) {
            abort(404);
        }

        // Only show approved reviews unless user is the author or a moderator
        if (!$review->approved && 
            !$review->canBeEditedBy(request()->user()) && 
            !$review->canBeModeratedBy(request()->user())) {
            abort(404);
        }

        $review->load('user:id,name,email');

        return response()->json(['review' => $review]);
    }

    /**
     * Update the specified review.
     */
    public function update(UpdateReviewRequest $request, Review $review): JsonResponse
    {
        // Ensure review belongs to current salon
        if ($review->salon_id !== app('tenant')->id) {
            abort(404);
        }

        $validated = $request->validated();
        $review->update($validated);
        $review->load('user:id,name,email');

        return response()->json([
            'message' => 'Bewertung wurde aktualisiert.',
            'review' => $review
        ]);
    }

    /**
     * Remove the specified review.
     */
    public function destroy(Request $request, Review $review): JsonResponse
    {
        // Ensure review belongs to current salon
        if ($review->salon_id !== app('tenant')->id) {
            abort(404);
        }

        // Check if user can delete this review
        if (!$review->canBeDeletedBy($request->user())) {
            abort(403, 'Sie können diese Bewertung nicht löschen.');
        }

        $review->delete();

        return response()->json([
            'message' => 'Bewertung wurde gelöscht.',
            'ok' => true
        ]);
    }

    /**
     * Toggle the approval status of a review (moderation).
     */
    public function toggleApproval(Request $request, Review $review): JsonResponse
    {
        // Ensure review belongs to current salon
        if ($review->salon_id !== app('tenant')->id) {
            abort(404);
        }

        // Check if user can moderate reviews
        if (!$review->canBeModeratedBy($request->user())) {
            abort(403, 'Sie haben keine Berechtigung, Bewertungen zu moderieren.');
        }

        $review->approved = !$review->approved;
        $review->save();
        $review->load('user:id,name,email');

        return response()->json([
            'message' => $review->approved ? 'Bewertung wurde freigegeben.' : 'Bewertung wurde verborgen.',
            'review' => $review
        ]);
    }

    /**
     * Get my review for the current salon.
     */
    public function myReview(Request $request): JsonResponse
    {
        if (!$request->user()) {
            return response()->json(['review' => null]);
        }

        $review = Review::where('salon_id', app('tenant')->id)
            ->where('user_id', $request->user()->id)
            ->where('source', 'local')
            ->with('user:id,name,email')
            ->first();

        return response()->json(['review' => $review]);
    }

    /**
     * Get all reviews for moderation (salon owners/managers only).
     */
    public function moderation(Request $request): JsonResponse
    {
        $salon = app('tenant');
        
        // Check if user can moderate reviews
        if (!$request->user()->hasAnyRole(['salon_owner', 'salon_manager'])) {
            abort(403);
        }

        $query = Review::where('salon_id', $salon->id)
            ->with(['user:id,name,email'])
            ->orderByDesc('created_at');

        // Filter by approval status
        if ($request->has('approved')) {
            $query->where('approved', $request->boolean('approved'));
        }

        $reviews = $query->paginate($this->perPage($request, 20, 50));

        return response()->json(['items' => $reviews]);
    }

    /**
     * Get rating distribution for the salon.
     */
    private function getRatingDistribution(int $salonId): array
    {
        $distribution = Review::where('salon_id', $salonId)
            ->where('approved', true)
            ->selectRaw('rating, COUNT(*) as count')
            ->groupBy('rating')
            ->pluck('count', 'rating')
            ->toArray();

        // Ensure all ratings 1-5 are present
        $result = [];
        for ($i = 1; $i <= 5; $i++) {
            $result[$i] = $distribution[$i] ?? 0;
        }

        return $result;
    }
}