<?php

namespace App\Policies;

use App\Models\User;
use App\Models\GalleryAlbum;

class GalleryAlbumPolicy
{
    public function view(User $user, GalleryAlbum $album): bool
    {
        // Public albums can be viewed by anyone
        if ($album->visibility === 'public') {
            return true;
        }

        // Private/unlisted albums require authentication
        return $user !== null;
    }

    public function create(User $user): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager']);
    }

    public function update(User $user, GalleryAlbum $album): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager']) ||
               $album->created_by === $user->id;
    }

    public function delete(User $user, GalleryAlbum $album): bool
    {
        return $user->hasRole(['salon_owner', 'salon_manager']) ||
               $album->created_by === $user->id;
    }
}
