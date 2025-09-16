<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class ContentBlock extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id','type','title','config','is_active','position'
    ];

    protected $casts = [
        'config'    => 'array',
        'is_active' => 'boolean',
    ];
}