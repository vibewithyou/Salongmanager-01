<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PurchaseOrderItem extends Model 
{
    protected $fillable = [
        'po_id',
        'product_id',
        'qty',
        'unit_cost'
    ];
    
    protected $casts = [
        'unit_cost' => 'decimal:2'
    ];
    
    public function purchaseOrder()
    {
        return $this->belongsTo(PurchaseOrder::class, 'po_id');
    }
    
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}