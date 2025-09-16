<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Salon extends Model
{
    protected $fillable = [
        'name', 'slug', 'primary_color', 'secondary_color', 'logo_path', 'brand', 'seo', 'social', 'content_settings'
    ];

    protected $casts = [
        'brand' => 'array',
        'seo' => 'array',
        'social' => 'array',
        'content_settings' => 'array',
    ];
}