<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SalonOwned;

class Supplier extends Model 
{
    use SalonOwned;
    
    protected $fillable = [
        'salon_id',
        'name',
        'email',
        'phone',
        'address',
        'meta'
    ];
    
    protected $casts = [
        'address' => 'array',
        'meta' => 'array'
    ];
    
    public function products()
    {
        return $this->hasMany(Product::class);
    }
    
    public function purchaseOrders()
    {
        return $this->hasMany(PurchaseOrder::class);
    }
}