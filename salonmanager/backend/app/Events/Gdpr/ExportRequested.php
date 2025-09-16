<?php

namespace App\Events\Gdpr;

class ExportRequested
{
    public function __construct(
        public int $userId,
        public int $gdprId
    ) {}
}