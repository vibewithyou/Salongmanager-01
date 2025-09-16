<?php

namespace App\Http\Controllers;

use App\Http\Requests\BookingCreateRequest;
use App\Models\Booking;
use App\Models\Service;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function store(BookingCreateRequest $request): JsonResponse
    {
        $user = $request->user();
        $salon = app('tenant');
        $data = $request->validated();

        // TODO: check availability logic
        $start = Carbon::parse($data['start_at']);
        $duration = 0;
        $price = 0;
        
        foreach ($data['services'] as $serviceData) {
            $service = Service::findOrFail($serviceData['id']);
            $duration += $service->base_duration;
            $price += $service->base_price;
        }
        
        $end = (clone $start)->addMinutes($duration);

        $booking = Booking::create([
            'salon_id' => $salon->id,
            'customer_id' => $user->id,
            'stylist_id' => $data['stylist_id'] ?? null,
            'start_at' => $start,
            'end_at' => $end,
            'status' => Booking::STATUS_PENDING,
            'notes' => $data['notes'] ?? null,
        ]);

        foreach ($data['services'] as $serviceData) {
            $service = Service::findOrFail($serviceData['id']);
            $booking->services()->attach($service->id, [
                'duration' => $service->base_duration,
                'price' => $service->base_price,
                'stylist_id' => $data['stylist_id'] ?? null,
            ]);
        }

        // TODO: handle images upload
        if (isset($data['images']) && is_array($data['images'])) {
            foreach ($data['images'] as $imagePath) {
                $booking->media()->create([
                    'path' => $imagePath,
                    'type' => 'image',
                ]);
            }
        }

        return response()->json([
            'booking' => $booking->load('services', 'media')
        ], 201);
    }

    public function confirm(Booking $booking): JsonResponse
    {
        // TODO: Add authorization check - stylist can only confirm assigned bookings
        $booking->update(['status' => Booking::STATUS_CONFIRMED]);
        
        // TODO: Send notification to customer
        // TODO: Send notification to stylist
        
        return response()->json([
            'message' => 'Booking confirmed successfully',
            'booking' => $booking->load('services', 'media')
        ]);
    }

    public function decline(Booking $booking, Request $request): JsonResponse
    {
        // TODO: Add authorization check - stylist can only decline assigned bookings
        $booking->update(['status' => Booking::STATUS_DECLINED]);
        
        // TODO: Auto-suggest alternative stylists
        // TODO: Send notification to customer with alternatives
        
        return response()->json([
            'message' => 'Booking declined successfully',
            'booking' => $booking->load('services', 'media')
        ]);
    }

    public function cancel(Booking $booking): JsonResponse
    {
        // TODO: Add authorization check - customer can only cancel own bookings
        $booking->update(['status' => Booking::STATUS_CANCELED]);
        
        // TODO: Send notification to stylist
        // TODO: Handle cancellation policy (refunds, etc.)
        
        return response()->json([
            'message' => 'Booking canceled successfully',
            'booking' => $booking->load('services', 'media')
        ]);
    }

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $query = Booking::with('services', 'media', 'stylist', 'customer');

        // Filter based on user role
        if ($user->hasRole('customer')) {
            $query->where('customer_id', $user->id);
        } elseif ($user->hasRole('stylist')) {
            $query->where('stylist_id', $user->stylist->id);
        }
        // Salon owners and managers can see all bookings in their salon

        $bookings = $query->orderBy('start_at', 'desc')->paginate(15);

        return response()->json($bookings);
    }

    public function services(): JsonResponse
    {
        $services = Service::all();
        return response()->json(['data' => $services]);
    }

    public function stylists(): JsonResponse
    {
        $stylists = Stylist::with('user')->get();
        return response()->json(['data' => $stylists]);
    }
}