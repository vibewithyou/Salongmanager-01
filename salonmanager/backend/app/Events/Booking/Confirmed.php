<?php

namespace App\Events\Booking;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class Confirmed
{
    use Dispatchable, SerializesModels;

    public function __construct(public int $bookingId)
    {
        //
    }
}