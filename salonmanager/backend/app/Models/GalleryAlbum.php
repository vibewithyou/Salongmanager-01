<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GalleryAlbum extends Model
{
    use HasFactory;

    protected $fillable = [
        'salon_id',
        'title',
        'visibility',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'visibility' => 'string',
        ];
    }

    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function photos(): HasMany
    {
        return $this->hasMany(GalleryPhoto::class, 'album_id');
    }

    public function approvedPhotos(): HasMany
    {
        return $this->hasMany(GalleryPhoto::class, 'album_id')
            ->whereNotNull('approved_at')
            ->whereNull('rejected_at');
    }
}
