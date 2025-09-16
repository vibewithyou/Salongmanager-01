<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class LoyaltyTransaction extends Model
{
    use SalonOwned;

    protected $fillable = ['salon_id', 'card_id', 'delta', 'reason', 'meta'];
    protected $casts = ['meta' => 'array'];

    public function card()
    {
        return $this->belongsTo(LoyaltyCard::class, 'card_id');
    }
}