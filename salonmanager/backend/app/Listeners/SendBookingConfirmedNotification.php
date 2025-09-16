<?php

namespace App\Listeners;

use App\Events\Booking\Confirmed;
use App\Mail\BookingConfirmed;
use App\Models\Booking;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Mail;

class SendBookingConfirmedNotification implements ShouldQueue
{
    use InteractsWithQueue;

    public function handle(Confirmed $event): void
    {
        $booking = $event->booking;
        
        if (!$booking instanceof Booking) {
            return;
        }

        $customer = $booking->customer;
        $stylist = $booking->stylist;
        $salon = $booking->salon;

        if (!$customer || !$stylist || !$salon) {
            return;
        }

        Mail::to($customer->email)->send(new BookingConfirmed(
            customerName: $customer->name,
            stylistName: $stylist->name,
            salonName: $salon->name,
            startAt: $booking->start_at->format('d.m.Y H:i')
        ));
    }
}
