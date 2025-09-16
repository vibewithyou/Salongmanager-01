<?php

namespace App\Events\Pos;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class InvoicePaid
{
    use Dispatchable, SerializesModels;

    public function __construct(public int $invoiceId)
    {
        //
    }
}