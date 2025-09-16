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
            \App\Listeners\AssignDefaultCustomerRole::class,
        ],
        
        // Booking events
        \App\Events\BookingConfirmed::class => [
            \App\Listeners\SendBookingConfirmedNotification::class,
        ],
        
        // Notification listeners
        \App\Events\Booking\Confirmed::class => [
            \App\Listeners\Notify\BookingConfirmedListener::class,
            \App\Listeners\SendBookingConfirmedNotification::class,
            \App\Listeners\Audit\BookingAuditListener::class.'@confirmed',
        ],
        \App\Events\Booking\Declined::class  => [
            \App\Listeners\Notify\BookingDeclinedListener::class,
            \App\Listeners\Audit\BookingAuditListener::class.'@declined',
        ],
        \App\Events\Booking\Canceled::class  => [
            \App\Listeners\Notify\BookingCanceledListener::class,
            \App\Listeners\Audit\BookingAuditListener::class.'@canceled',
        ],
        \App\Events\Pos\InvoicePaid::class   => [
            \App\Listeners\Notify\InvoicePaidListener::class,
            \App\Listeners\Audit\PosAuditListener::class.'@paid',
        ],
        \App\Events\Media\ConsentRequested::class => [
            \App\Listeners\Notify\MediaConsentRequestedListener::class,
            \App\Listeners\Audit\MediaAuditListener::class.'@consentRequested',
        ],
        
        // POS audit events
        \App\Events\Pos\InvoiceRefunded::class => [\App\Listeners\Audit\PosAuditListener::class.'@refunded'],
        
        // Media audit events
        \App\Events\Media\Uploaded::class            => [\App\Listeners\Audit\MediaAuditListener::class.'@uploaded'],
        \App\Events\Media\ConsentApproved::class     => [\App\Listeners\Audit\MediaAuditListener::class.'@consentApproved'],
        \App\Events\Media\ConsentRevoked::class      => [\App\Listeners\Audit\MediaAuditListener::class.'@consentRevoked'],
        
        // RBAC audit events
        \App\Events\Rbac\RoleGranted::class => [\App\Listeners\Audit\RbacAuditListener::class.'@granted'],
        \App\Events\Rbac\RoleRevoked::class => [\App\Listeners\Audit\RbacAuditListener::class.'@revoked'],
        
        // GDPR audit events
        \App\Events\Gdpr\Exported::class         => [\App\Listeners\Audit\GdprAuditListener::class.'@export'],
        \App\Events\Gdpr\DeletionRequested::class=> [\App\Listeners\Audit\GdprAuditListener::class.'@deleteRequested'],
        \App\Events\Gdpr\DeletionConfirmed::class=> [\App\Listeners\Audit\GdprAuditListener::class.'@deleteConfirmed'],
        
        // Auth audit events
        \Illuminate\Auth\Events\Login::class  => [\App\Listeners\Audit\AuthAuditListener::class.'@login'],
        \Illuminate\Auth\Events\Logout::class => [\App\Listeners\Audit\AuthAuditListener::class.'@logout'],
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