<?php

namespace App\Policies;

use App\Models\User;
use App\Models\ContentBlock;

class ContentBlockPolicy
{
    public function viewAny(User $user): bool { 
        return true; // public read
    }
    
    public function create(User $user): bool { 
        return $user->hasAnyRole(['salon_owner','salon_manager']); 
    }
    
    public function update(User $user, ContentBlock $block): bool { 
        return $user->hasAnyRole(['salon_owner','salon_manager']); 
    }
    
    public function delete(User $user, ContentBlock $block): bool { 
        return $user->hasAnyRole(['salon_owner','salon_manager']); 
    }
}