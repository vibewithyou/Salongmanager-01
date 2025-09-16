<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

class Salon extends Model
{
    protected $fillable = [
        'name', 'slug', 'primary_color', 'secondary_color', 'logo_path', 'brand', 'seo', 'social', 'content_settings',
        'short_desc', 'tags', 'location', 'address_line1', 'address_line2', 'city', 'zip', 'country'
    ];

    protected $casts = [
        'brand' => 'array',
        'seo' => 'array',
        'social' => 'array',
        'content_settings' => 'array',
        'tags' => 'array',
    ];

    public function openingHours() { 
        return $this->hasMany(OpeningHour::class); 
    }

    public function scopePublicFields($q) {
        return $q->select([
            'id','name','slug','logo_path','short_desc',
            'primary_color','secondary_color',
            'address_line1','address_line2','city','zip','country',
            DB::raw('ST_X(location) as lat'),
            DB::raw('ST_Y(location) as lng'),
        ]);
    }
}