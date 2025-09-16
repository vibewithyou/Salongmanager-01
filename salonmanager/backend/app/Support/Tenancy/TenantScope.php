<?php

namespace App\Support\Tenancy;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;

class TenantScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        if (!app()->bound('tenant')) {
            // No tenant resolved: block data exposure
            $builder->whereRaw('1=0');
            return;
        }
        $tenant = app('tenant');
        if ($model->getTable() && \Schema::hasColumn($model->getTable(), 'salon_id')) {
            $builder->where($model->getTable().'.salon_id', $tenant->id);
        }
    }
}

