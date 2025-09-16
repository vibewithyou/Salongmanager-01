<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class Shift extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id', 'stylist_id', 'user_id', 'start_at', 'end_at', 'status', 'meta',
        'role', 'title', 'rrule', 'exdates', 'published'
    ];
    
    protected $casts = [
        'start_at' => 'datetime', 
        'end_at' => 'datetime', 
        'meta' => 'array',
        'exdates' => 'array',
        'published' => 'boolean'
    ];

    public function stylist()
    {
        return $this->belongsTo(Stylist::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}