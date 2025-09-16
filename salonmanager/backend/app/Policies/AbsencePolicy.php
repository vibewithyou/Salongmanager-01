<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Absence;

class AbsencePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist', 'owner', 'platform_admin']);
    }

    public function create(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist']);
    }

    public function update(User $user, Absence $absence): bool
    {
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) {
            return true;
        }
        // stylist can edit own request while requested
        return $user->hasRole('stylist') && $absence->status === 'requested';
    }

    public function delete(User $user, Absence $absence): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager']);
    }

    public function approve(User $user, Absence $absence): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager']);
    }
}