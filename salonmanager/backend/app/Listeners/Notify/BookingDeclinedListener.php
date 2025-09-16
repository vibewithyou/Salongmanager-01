<?php
namespace App\Listeners\Notify;

use App\Models\{Booking, Invoice, MediaFile, User};
use App\Services\Notify\Notifier;

class BookingDeclinedListener {
  public function handle($event): void {
    $b = Booking::with(['customer','stylist'])->find($event->bookingId);
    if (!$b) return;
    $data = [
      'user'=> ['name'=>$b->customer?->name],
      'booking'=> ['id'=>$b->id,'start'=>$b->start_at,'service'=>$b->service_name ?? 'Service'],
      'salon'=> ['name'=>app('tenant')->name ?? 'Salon']
    ];
    Notifier::send([
      'salon_id'=>$b->salon_id, 'event'=>'booking.declined', 'user'=>$b->customer, 'data'=>$data,
      'ref'=>['type'=>'Booking','id'=>$b->id]
    ]);
  }
}