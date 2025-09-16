<?php

namespace App\Models;

use App\Support\Tenancy\SalonOwned;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Invoice extends Model
{
    use SalonOwned;

    protected $fillable = [
        'salon_id',
        'pos_session_id',
        'customer_id',
        'number',
        'issued_at',
        'total_net',
        'total_tax',
        'total_gross',
        'tax_breakdown',
        'status',
        'payment_id',
        'payment_provider',
        'meta'
    ];

    protected $casts = [
        'issued_at' => 'datetime',
        'tax_breakdown' => 'array',
        'meta' => 'array',
    ];

    public function salon(): BelongsTo
    {
        return $this->belongsTo(Salon::class);
    }

    public function posSession(): BelongsTo
    {
        return $this->belongsTo(PosSession::class);
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function items(): HasMany
    {
        return $this->hasMany(InvoiceItem::class);
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function refunds(): HasMany
    {
        return $this->hasMany(Refund::class);
    }

    /**
     * Finalize invoice number using GoBD-compliant sequential numbering
     */
    public function finalizeNumber(): void
    {
        if ($this->number) return;
        $this->number = \App\Services\Billing\InvoiceNumberService::nextNumber($this->salon_id);
        $this->save();
    }
}