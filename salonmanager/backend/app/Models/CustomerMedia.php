<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class CustomerMedia extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'customer_id', 'path', 'type', 'meta'];
    protected $casts = ['meta' => 'array'];
}