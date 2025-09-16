<?php

namespace App\Policies;

use App\Models\User;

class InventoryPolicy 
{
    public function read(User $user): bool 
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist']);
    }
    
    public function write(User $user): bool 
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager']);
    }
    
    public function consume(User $user): bool 
    {
        return $user->hasAnyRole(['salon_owner', 'salon_manager', 'stylist']); // Warenausgang
    }
}