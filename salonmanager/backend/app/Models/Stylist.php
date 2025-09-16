<?php

namespace App\Models;

use App\Support\Tenancy\SalonOwned;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Stylist extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id',
        'user_id',
        'display_name',
        'skills',
    ];

    protected $casts = [
        'skills' => 'array',
    ];

    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }

    public function bookingServices(): HasMany
    {
        return $this->hasMany(BookingService::class);
    }
}