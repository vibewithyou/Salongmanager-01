<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GalleryConsent extends Model
{
    use HasFactory;

    protected $fillable = [
        'salon_id',
        'customer_id',
        'photo_id',
        'status',
        'note',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'status' => 'string',
        ];
    }

    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(CustomerProfile::class, 'customer_id');
    }

    public function photo(): BelongsTo
    {
        return $this->belongsTo(GalleryPhoto::class, 'photo_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }

    public function isRequested(): bool
    {
        return $this->status === 'requested';
    }

    public function isRevoked(): bool
    {
        return $this->status === 'revoked';
    }
}
