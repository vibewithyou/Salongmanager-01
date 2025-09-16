<?php

namespace App\Listeners;

use App\Events\BookingConfirmed;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;

class SendBookingConfirmedNotification implements ShouldQueue
{
    use InteractsWithQueue;

    public function handle(BookingConfirmed $event): void
    {
        try {
            $booking = $event->booking;
            
            // Load necessary relationships
            $booking->load(['user', 'services', 'staff']);
            
            if (!$booking->user) {
                Log::warning('Booking confirmed but no user found', ['booking_id' => $booking->id]);
                return;
            }
            
            // Send email notification
            Mail::to($booking->user->email)->send(
                new \App\Mail\BookingConfirmedMail($booking)
            );
            
            Log::info('Booking confirmation email sent', [
                'booking_id' => $booking->id,
                'user_email' => $booking->user->email
            ]);
            
        } catch (\Exception $e) {
            Log::error('Failed to send booking confirmation email', [
                'booking_id' => $event->booking->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            // Don't fail the job, just log the error
            $this->release(60); // Retry in 1 minute
        }
    }
}