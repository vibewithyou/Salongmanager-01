<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Salon extends Model
{
    protected $fillable = [
        'name', 'slug', 'primary_color', 'secondary_color'
    ];
}