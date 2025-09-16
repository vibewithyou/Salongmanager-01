<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class WorkRule extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id', 'max_hours_per_day', 'min_break_minutes_per6h'
    ];
}
