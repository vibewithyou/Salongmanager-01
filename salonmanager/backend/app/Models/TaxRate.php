<?php

namespace App\Models;

use App\Support\Tenancy\SalonOwned;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TaxRate extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id',
        'name',
        'rate',
        'active'
    ];

    protected $casts = [
        'rate' => 'decimal:2',
        'active' => 'boolean',
    ];

    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }
}