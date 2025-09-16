<?php

namespace App\Models;

use App\Support\Tenancy\SalonOwned;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Refund extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id',
        'invoice_id',
        'amount',
        'reason',
        'lines',
        'refunded_at'
    ];

    protected $casts = [
        'refunded_at' => 'datetime',
        'lines' => 'array',
    ];

    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }

    public function invoice(): BelongsTo
    {
        return $this->belongsTo(Invoice::class);
    }
}