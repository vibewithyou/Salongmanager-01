<?php

namespace App\Events\Media;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ConsentRequested
{
    use Dispatchable, SerializesModels;

    public function __construct(public int $mediaFileId)
    {
        //
    }
}