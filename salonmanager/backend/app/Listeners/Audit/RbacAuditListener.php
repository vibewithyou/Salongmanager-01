<?php

namespace App\Listeners\Audit;

use App\Support\Audit\Audit;

class RbacAuditListener
{
    public function granted($event): void {
        Audit::write('rbac.role.granted','User',$event->userId,['role'=>$event->role,'salon_id'=>$event->salonId]);
    }
    public function revoked($event): void {
        Audit::write('rbac.role.revoked','User',$event->userId,['role'=>$event->role,'salon_id'=>$event->salonId]);
    }
}