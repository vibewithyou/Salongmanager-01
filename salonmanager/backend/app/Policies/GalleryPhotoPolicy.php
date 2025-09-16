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

        // Unlisted photos can be viewed by authenticated users
        if ($photo->isApproved() && $photo->album?->visibility === 'unlisted') {
            return $user !== null;
        }

        // Private customer photos can only be viewed by the customer, owner, manager, or stylist
        if ($photo->album?->visibility === 'private_customer') {
            if (!$user) {
                return false;
            }
            
            // Customer can view their own photos
            if ($photo->customer_id && $photo->customer_id === $user->id) {
                return true;
            }
            
            // Staff can view customer photos
            return $user->hasRole(['salon_owner', 'salon_manager', 'stylist']);
        }

        // Private photos require authentication and appropriate role
        if ($photo->album?->visibility === 'private') {
            return $user !== null && $user->hasRole(['salon_owner', 'salon_manager', 'stylist']);
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
