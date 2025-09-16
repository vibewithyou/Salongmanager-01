<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SalonOwned;

class PurchaseOrder extends Model 
{
    use SalonOwned;
    
    protected $fillable = [
        'salon_id',
        'supplier_id',
        'number',
        'status',
        'meta'
    ];
    
    protected $casts = [
        'meta' => 'array'
    ];
    
    public function supplier()
    {
        return $this->belongsTo(Supplier::class);
    }
    
    public function items()
    {
        return $this->hasMany(PurchaseOrderItem::class, 'po_id');
    }
}