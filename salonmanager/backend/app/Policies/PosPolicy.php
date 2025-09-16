<?php

namespace App\Policies;

use App\Models\User;

class PosPolicy
{
    public function usePos(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist']);
    }

    public function managePos(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager']);
    }
}