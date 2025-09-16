<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SalonOwned;

class StockMovement extends Model 
{
    use SalonOwned;
    
    protected $fillable = [
        'salon_id',
        'product_id',
        'location_id',
        'type',
        'delta',
        'meta',
        'moved_at'
    ];
    
    protected $casts = [
        'meta' => 'array',
        'moved_at' => 'datetime'
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