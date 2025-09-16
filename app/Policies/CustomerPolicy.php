<?php

namespace App\Policies;

use App\Models\User;

class CustomerPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist', 'owner', 'platform_admin']);
    }

    public function view(User $user, User $customer): bool
    {
        if ($user->id === $customer->id) return true; // customer sees self
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist', 'owner', 'platform_admin']);
    }

    public function update(User $user, User $customer): bool
    {
        if ($user->id === $customer->id) return true; // self-update allowed (limited by request rules/UI)
        return $user->hasAnyRole(['salon_owner', 'salon_manager']);
    }
}