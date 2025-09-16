<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SalonOwned;

class StockItem extends Model 
{
    use SalonOwned;
    
    protected $fillable = [
        'salon_id',
        'product_id',
        'location_id',
        'qty'
    ];
    
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
    
    public function location()
    {
        return $this->belongsTo(StockLocation::class, 'location_id');
    }
}