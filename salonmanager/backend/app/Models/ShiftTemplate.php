<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class ShiftTemplate extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'name', 'weekday', 'start_time', 'end_time', 'meta'];
    protected $casts = ['meta' => 'array'];
}