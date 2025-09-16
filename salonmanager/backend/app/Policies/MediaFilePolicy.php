<?php

namespace App\Policies;

use App\Models\User;
use App\Models\MediaFile;

class MediaFilePolicy
{
    public function view(?User $user, MediaFile $file): bool
    {
        if ($file->visibility === 'public') return true;
        if (!$user) return false;
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist']);
    }

    public function manage(User $user, MediaFile $file): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager']);
    }
}