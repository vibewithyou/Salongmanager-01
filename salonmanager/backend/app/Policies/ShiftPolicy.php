<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Shift;

class ShiftPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist', 'owner', 'platform_admin']);
    }

    public function create(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager']);
    }

    public function update(User $user, Shift $shift): bool
    {
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) {
            return true;
        }
        // stylist may confirm/cancel own planned shifts
        return $user->hasRole('stylist') && $shift->stylist && $shift->stylist->user_id === $user->id;
    }

    public function delete(User $user, Shift $shift): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager']);
    }
}