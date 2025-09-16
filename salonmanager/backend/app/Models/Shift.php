<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class Shift extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'stylist_id', 'start_at', 'end_at', 'status', 'meta'];
    protected $casts = ['start_at' => 'datetime', 'end_at' => 'datetime', 'meta' => 'array'];

    public function stylist()
    {
        return $this->belongsTo(Stylist::class);
    }
}