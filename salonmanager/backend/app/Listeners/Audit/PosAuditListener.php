<?php

namespace App\Listeners\Audit;

use App\Support\Audit\Audit;

class PosAuditListener
{
    public function paid($event): void {
        Audit::write('pos.invoice.paid', 'Invoice', $event->invoiceId, []);
    }
    public function refunded($event): void {
        Audit::write('pos.invoice.refunded', 'Invoice', $event->invoiceId, []);
    }
}