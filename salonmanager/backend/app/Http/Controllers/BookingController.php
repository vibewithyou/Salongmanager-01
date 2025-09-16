<?php

namespace App\Http\Controllers;

use App\Http\Requests\Booking\StoreBookingRequest;
use App\Http\Requests\Booking\UpdateStatusRequest;
use App\Models\{Booking, MediaFile};
use App\Services\Booking\AvailabilityService;
use Illuminate\Support\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BookingController extends Controller
{
  public function store(StoreBookingRequest $r): JsonResponse
  {
    $v = $r->validated();
    $salonId = app('tenant')->id;
    $start = Carbon::parse($v['start_at']);
    $duration = (int)$v['duration'];
    $bufB = (int)($v['buffer_before'] ?? 0);
    $bufA = (int)($v['buffer_after'] ?? 0);

    // Availability
    if (!AvailabilityService::isFree($salonId, (int)$v['stylist_id'], $start, $duration, $bufB, $bufA)) {
      if (!empty($v['suggest_if_conflict'])) {
        $sugs = AvailabilityService::suggestions($salonId, (int)$v['stylist_id'], $start, $duration, $bufB, $bufA, 6);
        return response()->json(['error'=>'conflict','suggestions'=>$sugs], 409);
      }
      return response()->json(['error'=>'conflict'], 409);
    }

    $end = (clone $start)->addMinutes($duration);
    $booking = Booking::create([
      'salon_id'=>$salonId,
      'customer_id'=>$v['customer_id'],
      'stylist_id'=>$v['stylist_id'],
      'service_id'=>$v['service_id'],
      'start_at'=>$start,
      'end_at'=>$end,
      'duration'=>$duration,
      'buffer_before'=>$bufB,
      'buffer_after'=>$bufA,
      'status'=>'pending',
      'note'=>$v['note'] ?? null,
    ]);

    // Attach media (optional)
    foreach (($v['media_ids'] ?? []) as $mid) {
      \DB::table('booking_media')->insert(['booking_id'=>$booking->id,'media_file_id'=>$mid]);
    }

    // Notify (Prompt 15)
    event(new \App\Events\Booking\Created($booking->id));
    \App\Support\Audit\Audit::write('booking.created','Booking',$booking->id,[]);

    return response()->json(['booking'=>$booking], 201);
  }

  public function updateStatus(UpdateStatusRequest $r, Booking $booking): JsonResponse
  {
    $this->authorize($r->input('action') === 'cancel' ? 'cancel' : 'modify', $booking);

    $action = $r->validated()['action'];
    $reason = $r->validated()['reason'] ?? null;

    if ($action === 'confirm') {
      $booking->status = 'confirmed';
      $booking->save();
      event(new \App\Events\Booking\Confirmed($booking->id));
      \App\Support\Audit\Audit::write('booking.confirmed','Booking',$booking->id,[]);
      return response()->json(['booking'=>$booking]);
    }

    if ($action === 'decline') {
      $booking->status = 'declined';
      $booking->save();
      event(new \App\Events\Booking\Declined($booking->id));
      \App\Support\Audit\Audit::write('booking.declined','Booking',$booking->id,['reason'=>$reason]);
      return response()->json(['booking'=>$booking]);
    }

    if ($action === 'cancel') {
      // Storno-Policy (einfach): bis 24h vorher frei, sonst fee
      $hoursToStart = now()->diffInHours(\Illuminate\Support\Carbon::parse($booking->start_at), false);
      $fee = $hoursToStart < 24 ? 0.2 : 0.0; // 20% Gebühr Beispiel
      $booking->status = 'canceled';
      $booking->save();

      // Optional: Refund Hook (POS)
      if ($fee < 1.0) {
        // TODO(ASK): confirm invoice relation names & payment/ refund service
        // \App\Services\Pos\Refunds::refundBooking($booking->id, rate: (1.0 - $fee));
      }

      event(new \App\Events\Booking\Canceled($booking->id));
      \App\Support\Audit\Audit::write('booking.canceled','Booking',$booking->id,['fee_rate'=>$fee,'reason'=>$reason]);

      return response()->json(['booking'=>$booking,'fee_rate'=>$fee]);
    }

    return response()->json(['error'=>'unknown action'], 400);
  }

  public function attachMedia(Booking $booking): JsonResponse
  {
    $this->authorize('modify', $booking);
    request()->validate(['media_ids'=>'required|array','media_ids.*'=>'integer|exists:media_files,id']);
    foreach (request('media_ids') as $mid) {
      \DB::table('booking_media')->updateOrInsert(['booking_id'=>$booking->id,'media_file_id'=>$mid],[]);
    }
    \App\Support\Audit\Audit::write('booking.media.attach','Booking',$booking->id,['count'=>count(request('media_ids'))]);
    return response()->json(['ok'=>true]);
  }

  // Keep existing methods for backward compatibility
  public function index(Request $request): JsonResponse
  {
    $user = $request->user();
    $query = Booking::with('services', 'media', 'stylist', 'customer');

    // Filter based on user role
    if ($user->hasRole('customer')) {
      $query->where('customer_id', $user->id);
    } elseif ($user->hasRole('stylist')) {
      $query->where('stylist_id', $user->id);
    }
    // Salon owners and managers can see all bookings in their salon

    $bookings = $query->orderBy('start_at', 'desc')->paginate(15);

    return response()->json($bookings);
  }

  public function services(): JsonResponse
  {
    $services = \App\Models\Service::all();
    return response()->json(['data' => $services]);
  }

  public function stylists(): JsonResponse
  {
    $stylists = \App\Models\Stylist::with('user')->get();
    return response()->json(['data' => $stylists]);
  }

  // Legacy methods for backward compatibility
  public function confirm(Booking $booking): JsonResponse
  {
    return $this->updateStatus(new UpdateStatusRequest(['action' => 'confirm']), $booking);
  }

  public function decline(Booking $booking, Request $request): JsonResponse
  {
    return $this->updateStatus(new UpdateStatusRequest(['action' => 'decline', 'reason' => $request->input('reason')]), $booking);
  }

  public function cancel(Booking $booking): JsonResponse
  {
    return $this->updateStatus(new UpdateStatusRequest(['action' => 'cancel']), $booking);
  }
}