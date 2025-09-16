<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class CustomerProfile extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'user_id', 'phone', 'preferred_stylist', 'prefs', 'address'];
    protected $casts = ['prefs' => 'array', 'address' => 'array'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}