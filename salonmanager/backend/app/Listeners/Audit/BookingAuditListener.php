<?php

namespace App\Listeners\Audit;

use App\Support\Audit\Audit;

class BookingAuditListener
{
    public function confirmed($event): void { $this->log('booking.confirmed', $event->bookingId); }
    public function declined($event): void  { $this->log('booking.declined',  $event->bookingId); }
    public function canceled($event): void  { $this->log('booking.canceled',  $event->bookingId); }

    protected function log(string $action, int $id): void {
        Audit::write($action, 'Booking', $id, []);
    }
}