<?php

namespace App\Events\Gdpr;

class DeletionConfirmed
{
    public function __construct(
        public int $userId,
        public int $gdprId
    ) {}
}