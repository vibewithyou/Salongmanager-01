<?php

namespace App\Support\Audit;

use Illuminate\Support\Facades\Facade;

class AuditFacade extends Facade {
    protected static function getFacadeAccessor(){ return 'audit'; }
}