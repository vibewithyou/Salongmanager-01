<?php

namespace App\Models;

use App\Support\Tenancy\SalonOwned;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Service extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id',
        'name',
        'description',
        'base_duration',
        'base_price',
    ];

    protected $casts = [
        'base_duration' => 'integer',
        'base_price' => 'decimal:2',
    ];

    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }

    public function bookings(): BelongsToMany
    {
        return $this->belongsToMany(Booking::class, 'booking_services')
            ->withPivot('duration', 'price', 'stylist_id');
    }
}