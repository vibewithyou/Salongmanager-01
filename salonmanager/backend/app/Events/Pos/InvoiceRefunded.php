<?php

namespace App\Events\Pos;

use Illuminate\Foundation\Events\Dispatchable;

class InvoiceRefunded
{
    use Dispatchable;

    public function __construct(
        public int $invoiceId
    ) {}
}