<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SalonOwned;

class Product extends Model 
{
    use SalonOwned;
    
    protected $fillable = [
        'salon_id',
        'supplier_id',
        'sku',
        'barcode',
        'name',
        'description',
        'tax_rate',
        'reorder_point',
        'reorder_qty',
        'meta'
    ];
    
    protected $casts = [
        'meta' => 'array',
        'tax_rate' => 'decimal:2'
    ];
    
    public function supplier()
    {
        return $this->belongsTo(Supplier::class);
    }
    
    public function price()
    {
        return $this->hasOne(ProductPrice::class)->where('active', true);
    }
    
    public function prices()
    {
        return $this->hasMany(ProductPrice::class);
    }
    
    public function stockItems()
    {
        return $this->hasMany(StockItem::class);
    }
    
    public function stockMovements()
    {
        return $this->hasMany(StockMovement::class);
    }
    
    public function purchaseOrderItems()
    {
        return $this->hasMany(PurchaseOrderItem::class);
    }
}