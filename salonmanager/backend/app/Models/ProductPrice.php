<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductPrice extends Model 
{
    protected $fillable = [
        'product_id',
        'net_price',
        'tax_rate',
        'gross_price',
        'active'
    ];
    
    protected $casts = [
        'active' => 'boolean',
        'net_price' => 'decimal:2',
        'gross_price' => 'decimal:2',
        'tax_rate' => 'decimal:2'
    ];
    
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}