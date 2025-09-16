<?php

namespace App\Events\Gdpr;

use Illuminate\Foundation\Events\Dispatchable;

class DeletionRequested
{
    use Dispatchable;

    public function __construct(
        public int $userId
    ) {}
}