<?php

namespace App\Models;

use App\Support\Tenancy\SalonOwned;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InvoiceSequence extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id',
        'year',
        'current_no'
    ];

    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }
}