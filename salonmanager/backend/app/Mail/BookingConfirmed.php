<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class BookingConfirmed extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public string $customerName,
        public string $stylistName,
        public string $salonName,
        public string $startAt
    ) {}

    public function build()
    {
        return $this->view('mails.booking_confirmed')
            ->subject('Buchung bestätigt - ' . config('app.name'));
    }
}
