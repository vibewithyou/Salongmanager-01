<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class Absence extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id', 'stylist_id', 'user_id', 'from_date', 'to_date', 
        'start_at', 'end_at', 'type', 'status', 'note', 'reason'
    ];
    
    protected $casts = [
        'from_date' => 'date', 
        'to_date' => 'date',
        'start_at' => 'datetime',
        'end_at' => 'datetime'
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