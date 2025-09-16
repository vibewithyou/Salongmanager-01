<?php

namespace App\Events\Media;

use Illuminate\Foundation\Events\Dispatchable;

class ConsentApproved
{
    use Dispatchable;

    public function __construct(
        public int $mediaFileId
    ) {}
}