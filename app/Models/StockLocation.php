<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Traits\SalonOwned;

class StockLocation extends Model 
{
    use SalonOwned;
    
    protected $fillable = [
        'salon_id',
        'name',
        'is_default',
        'meta'
    ];
    
    protected $casts = [
        'is_default' => 'boolean',
        'meta' => 'array'
    ];
    
    public function stockItems()
    {
        return $this->hasMany(StockItem::class, 'location_id');
    }
    
    public function stockMovements()
    {
        return $this->hasMany(StockMovement::class, 'location_id');
    }
}