<?php

namespace App\Support\Tenancy;

use Illuminate\Database\Eloquent\Model;

trait SalonOwned
{
    public static function bootSalonOwned(): void
    {
        static::addGlobalScope(new TenantScope);

        static::creating(function (Model $model) {
            if (app()->bound('tenant') && empty($model->salon_id)) {
                $model->salon_id = app('tenant')->id;
            }
        });
    }
}

