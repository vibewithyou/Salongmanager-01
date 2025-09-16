<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use App\Models\Shift;
use App\Models\Absence;
use App\Models\User;
use App\Models\CustomerNote;
use App\Models\LoyaltyCard;
use App\Policies\ShiftPolicy;
use App\Policies\AbsencePolicy;
use App\Policies\CustomerPolicy;
use App\Policies\CustomerNotePolicy;
use App\Policies\LoyaltyPolicy;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        Shift::class => ShiftPolicy::class,
        Absence::class => AbsencePolicy::class,
        User::class => CustomerPolicy::class,
        CustomerNote::class => CustomerNotePolicy::class,
        LoyaltyCard::class => LoyaltyPolicy::class,
    ];

    /**
     * Register any authentication / authorization services.
     */
    public function boot(): void
    {
        //
    }
}