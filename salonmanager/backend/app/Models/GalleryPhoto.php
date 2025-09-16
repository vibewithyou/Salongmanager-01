<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GalleryPhoto extends Model
{
    use HasFactory;

    protected $fillable = [
        'salon_id',
        'album_id',
        'customer_id',
        'path',
        'variants',
        'before_after_group',
        'approved_at',
        'rejected_at',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'variants' => 'array',
            'approved_at' => 'datetime',
            'rejected_at' => 'datetime',
            'before_after_group' => 'string',
        ];
    }

    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }

    public function album(): BelongsTo
    {
        return $this->belongsTo(GalleryAlbum::class, 'album_id');
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(CustomerProfile::class, 'customer_id');
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function consents(): HasMany
    {
        return $this->hasMany(GalleryConsent::class, 'photo_id');
    }

    public function likes(): HasMany
    {
        return $this->hasMany(GalleryLike::class, 'photo_id');
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(GalleryFavorite::class, 'photo_id');
    }

    public function beforeAfterPhotos(): HasMany
    {
        return $this->hasMany(GalleryPhoto::class, 'before_after_group', 'before_after_group')
            ->where('id', '!=', $this->id);
    }

    public function isApproved(): bool
    {
        return !is_null($this->approved_at) && is_null($this->rejected_at);
    }

    public function isRejected(): bool
    {
        return !is_null($this->rejected_at);
    }

    public function scopeApproved($query)
    {
        return $query->whereNotNull('approved_at')->whereNull('rejected_at');
    }

    public function scopePublic($query)
    {
        return $query->whereHas('album', function ($q) {
            $q->where('visibility', 'public');
        });
    }
}
