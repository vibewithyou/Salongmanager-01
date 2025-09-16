<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class Absence extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'stylist_id', 'from_date', 'to_date', 'type', 'status', 'note'];
    protected $casts = ['from_date' => 'date', 'to_date' => 'date'];

    public function stylist()
    {
        return $this->belongsTo(Stylist::class);
    }
}