<?php

namespace App\Policies;

use App\Models\User;
use App\Models\GalleryConsent;

class GalleryConsentPolicy
{
    public function view(User $user, GalleryConsent $consent): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager', 'stylist']) ||
               $consent->created_by === $user->id;
    }

    public function create(User $user): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager', 'stylist', 'customer']);
    }

    public function update(User $user, GalleryConsent $consent): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager']) ||
               $consent->created_by === $user->id;
    }

    public function delete(User $user, GalleryConsent $consent): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager']) ||
               $consent->created_by === $user->id;
    }
}
