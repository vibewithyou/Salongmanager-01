<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class Discount extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'code', 'type', 'value', 'valid_from', 'valid_to', 'active', 'conditions'];
    protected $casts = [
        'conditions' => 'array',
        'valid_from' => 'date',
        'valid_to' => 'date',
        'active' => 'boolean'
    ];
}