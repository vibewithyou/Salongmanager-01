<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class GdprRequest extends Model
{
    use HasFactory, SalonOwned;

    protected $fillable = [
        'salon_id',
        'user_id',
        'type',
        'status',
        'payload'
    ];

    protected $casts = [
        'payload' => 'array'
    ];

    /**
     * Get the user that owns the GDPR request.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the salon that owns the GDPR request.
     */
    public function salon()
    {
        return $this->belongsTo(Salon::class);
    }
}