<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Review extends Model
{
    use HasFactory;
    use \App\Support\Tenancy\SalonOwned;

    protected $fillable = [
        'salon_id',
        'user_id',
        'rating',
        'body',
        'media_ids',
        'source',
        'source_id',
        'author_name',
        'approved'
    ];

    protected $casts = [
        'media_ids' => 'array',
        'approved' => 'boolean',
        'rating' => 'integer'
    ];

    /**
     * Get the user who wrote the review.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the salon that was reviewed.
     */
    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }

    /**
     * Scope to only approved reviews.
     */
    public function scopeApproved($query)
    {
        return $query->where('approved', true);
    }

    /**
     * Scope to only local reviews.
     */
    public function scopeLocal($query)
    {
        return $query->where('source', 'local');
    }

    /**
     * Scope to only Google reviews.
     */
    public function scopeGoogle($query)
    {
        return $query->where('source', 'google');
    }

    /**
     * Check if the review is from Google.
     */
    public function isFromGoogle(): bool
    {
        return $this->source === 'google';
    }

    /**
     * Check if the review can be edited by the given user.
     */
    public function canBeEditedBy(?User $user): bool
    {
        if (!$user) {
            return false;
        }

        // Google reviews cannot be edited
        if ($this->isFromGoogle()) {
            return false;
        }

        // Only the author can edit their own review
        return $this->user_id === $user->id;
    }

    /**
     * Check if the review can be deleted by the given user.
     */
    public function canBeDeletedBy(?User $user): bool
    {
        return $this->canBeEditedBy($user);
    }

    /**
     * Check if the review can be moderated by the given user.
     */
    public function canBeModeratedBy(?User $user): bool
    {
        if (!$user) {
            return false;
        }

        // Check if user has salon owner or manager role for this salon
        return $user->hasAnyRole(['salon_owner', 'salon_manager']) && 
               $user->current_salon_id === $this->salon_id;
    }
}