<?php

namespace App\Policies;

use App\Models\User;
use App\Models\CustomerNote;

class CustomerNotePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist']);
    }

    public function create(User $user): bool
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist']);
    }

    public function update(User $user, CustomerNote $note): bool
    {
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) return true;
        return $note->author_id === $user->id; // stylist may edit own note
    }

    public function delete(User $user, CustomerNote $note): bool
    {
        if ($user->hasAnyRole(['salon_owner', 'salon_manager'])) return true;
        return $note->author_id === $user->id;
    }
}