<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class LoyaltyCard extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'customer_id', 'points', 'meta'];
    protected $casts = ['meta' => 'array'];

    public function tx()
    {
        return $this->hasMany(LoyaltyTransaction::class, 'card_id');
    }
}