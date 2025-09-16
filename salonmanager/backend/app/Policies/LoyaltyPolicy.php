<?php

namespace App\Policies;

use App\Models\User;
use App\Models\LoyaltyCard;

class LoyaltyPolicy
{
    public function view(User $user, LoyaltyCard $card): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager']) || $card->customer_id === $user->id;
    }

    public function adjust(User $user, LoyaltyCard $card): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist']); // stylist can add after service (policy can restrict)
    }
}