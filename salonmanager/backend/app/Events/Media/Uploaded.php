<?php

namespace App\Events\Media;

use Illuminate\Foundation\Events\Dispatchable;

class Uploaded
{
    use Dispatchable;

    public function __construct(
        public int $mediaFileId
    ) {}
}