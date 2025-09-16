<?php

namespace App\Events\Gdpr;

class DeletionRequested
{
    public function __construct(
        public int $userId,
        public int $gdprId
    ) {}
}