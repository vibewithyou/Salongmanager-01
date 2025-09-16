<?php

namespace App\Events\Booking;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class Declined
{
    use Dispatchable, SerializesModels;

    public function __construct(public int $bookingId)
    {
        //
    }
}