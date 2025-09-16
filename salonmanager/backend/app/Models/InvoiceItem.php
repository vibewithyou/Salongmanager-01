<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InvoiceItem extends Model
{
    protected $fillable = [
        'invoice_id',
        'type',
        'reference_id',
        'name',
        'qty',
        'unit_net',
        'tax_rate',
        'line_net',
        'line_tax',
        'line_gross',
        'meta'
    ];

    protected $casts = [
        'meta' => 'array',
    ];

    public function invoice(): BelongsTo
    {
        return $this->belongsTo(Invoice::class);
    }
}