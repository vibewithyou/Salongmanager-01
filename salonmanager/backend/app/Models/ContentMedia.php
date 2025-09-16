<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class ContentMedia extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id','path','meta'];
    protected $casts = ['meta'=>'array'];
}