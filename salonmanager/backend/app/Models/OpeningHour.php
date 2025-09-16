<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OpeningHour extends Model
{
    protected $fillable = ['salon_id','weekday','open_time','close_time','closed'];
    protected $casts = ['closed'=>'boolean'];
}