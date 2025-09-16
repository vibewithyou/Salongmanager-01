<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Salon;

class SalonPolicy
{
    public function view(User $user, Salon $salon): bool
    {
        return true; // public read
    }

    public function update(User $user, Salon $salon): bool
    {
        return $user->hasAnyRole(['salon_owner','salon_manager','owner','platform_admin']);
    }
}