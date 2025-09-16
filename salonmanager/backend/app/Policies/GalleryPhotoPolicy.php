<?php

namespace App\Policies;

use App\Models\User;
use App\Models\GalleryPhoto;

class GalleryPhotoPolicy
{
    public function view(User $user, GalleryPhoto $photo): bool
    {
        // Approved photos in public albums can be viewed by anyone
        if ($photo->isApproved() && $photo->album?->visibility === 'public') {
            return true;
        }

        // Other photos require authentication
        return $user !== null;
    }

    public function create(User $user): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager', 'stylist']);
    }

    public function update(User $user, GalleryPhoto $photo): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager']) ||
               $photo->created_by === $user->id;
    }

    public function moderate(User $user, GalleryPhoto $photo): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager']);
    }

    public function delete(User $user, GalleryPhoto $photo): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager']) ||
               $photo->created_by === $user->id;
    }
}
