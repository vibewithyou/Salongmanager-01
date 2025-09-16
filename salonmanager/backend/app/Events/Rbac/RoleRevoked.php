<?php

namespace App\Events\Rbac;

use Illuminate\Foundation\Events\Dispatchable;

class RoleRevoked
{
    use Dispatchable;

    public function __construct(
        public int $userId,
        public string $role,
        public int $salonId
    ) {}
}