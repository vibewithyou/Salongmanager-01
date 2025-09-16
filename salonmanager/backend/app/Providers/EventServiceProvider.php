<?php

namespace App\Providers;

use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Listeners\SendEmailVerificationNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

class EventServiceProvider extends ServiceProvider
{
    /**
     * The event to listener mappings for the application.
     *
     * @var array<class-string, array<int, class-string>>
     */
    protected $listen = [
        Registered::class => [
            SendEmailVerificationNotification::class,
        ],
        \App\Events\Booking\Confirmed::class => [\App\Listeners\Notify\BookingConfirmedListener::class],
        \App\Events\Booking\Declined::class  => [\App\Listeners\Notify\BookingDeclinedListener::class],
        \App\Events\Booking\Canceled::class  => [\App\Listeners\Notify\BookingCanceledListener::class],
        \App\Events\Pos\InvoicePaid::class   => [\App\Listeners\Notify\InvoicePaidListener::class],
        \App\Events\Media\ConsentRequested::class => [\App\Listeners\Notify\MediaConsentRequestedListener::class],
    ];

    /**
     * Register any events for your application.
     */
    public function boot(): void
    {
        //
    }

    /**
     * Determine if events and listeners should be automatically discovered.
     */
    public function shouldDiscoverEvents(): bool
    {
        return false;
    }
}