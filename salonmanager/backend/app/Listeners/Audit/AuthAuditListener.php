<?php

namespace App\Listeners\Audit;

use App\Support\Audit\Audit;

class AuthAuditListener
{
    public function login($event): void  { Audit::write('auth.login', 'User', $event->user->id, []); }
    public function logout($event): void { Audit::write('auth.logout','User', $event->user->id, []); }
}