<?php

namespace App\Events\Gdpr;

use Illuminate\Foundation\Events\Dispatchable;

class Exported
{
    use Dispatchable;

    public function __construct(
        public int $userId
    ) {}
}