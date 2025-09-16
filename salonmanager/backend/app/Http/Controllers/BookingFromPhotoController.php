<?php

namespace App\Http\Controllers;

use App\Models\GalleryPhoto;
use App\Models\Booking;
use App\Domain\Gallery\AI\Recommendations;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class BookingFromPhotoController extends Controller
{
    public function suggestedServices(GalleryPhoto $photo): JsonResponse
    {
        $this->authorize('view', $photo);

        try {
            $recommender = app(Recommendations::class);
            $suggestions = $recommender->suggestServicesForPhoto($photo->id);
            
            return response()->json([
                'suggested_services' => $suggestions,
            ])->header('X-AI', 'enabled');
        } catch (\Exception $e) {
            return response()->json([
                'suggested_services' => [],
            ])->header('X-AI', 'disabled');
        }
    }

    public function createBooking(Request $request, GalleryPhoto $photo): JsonResponse
    {
        $this->authorize('view', $photo);

        $data = $request->validate([
            'service_id' => ['required', 'exists:services,id'],
            'stylist_id' => ['nullable', 'exists:users,id'],
            'start_at' => ['nullable', 'date', 'after:now'],
        ]);

        try {
            DB::beginTransaction();

            // Create draft booking
            $booking = Booking::create([
                'salon_id' => app('tenant')->id,
                'customer_id' => auth()->id(),
                'service_id' => $data['service_id'],
                'stylist_id' => $data['stylist_id'],
                'start_at' => $data['start_at'] ?? now()->addDays(1),
                'status' => 'draft',
                'source' => 'photo:' . $photo->id,
                'notes' => 'Booking created from gallery photo',
            ]);

            DB::commit();

            return response()->json([
                'booking' => $booking->load(['service', 'stylist']),
                'next_steps' => [
                    'message' => 'Draft booking created successfully',
                    'actions' => [
                        'confirm' => "POST /api/v1/bookings/{$booking->id}/confirm",
                        'modify' => "PUT /api/v1/bookings/{$booking->id}",
                        'cancel' => "DELETE /api/v1/bookings/{$booking->id}",
                    ],
                ],
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'message' => 'Failed to create booking from photo',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
