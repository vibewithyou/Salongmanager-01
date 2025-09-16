<?php

namespace App\Listeners\Audit;

use App\Support\Audit\Audit;

class GdprAuditListener
{
    public function export($event): void {
        Audit::write('gdpr.export','User',$event->userId,[]);
    }
    public function deleteRequested($event): void {
        Audit::write('gdpr.delete.request','User',$event->userId,[]);
    }
    public function deleteConfirmed($event): void {
        Audit::write('gdpr.delete.confirm','User',$event->userId,[]);
    }
}