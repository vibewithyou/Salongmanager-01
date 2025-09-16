<?php

namespace App\Services\Inventory;

use App\Models\StockItem;
use App\Models\StockMovement;
use Illuminate\Support\Facades\DB;

class StockService 
{
    public static function adjust(int $salonId, int $productId, int $locationId, int $delta, string $type, array $meta = []): StockMovement 
    {
        return DB::transaction(function() use ($salonId, $productId, $locationId, $delta, $type, $meta) {
            $item = StockItem::firstOrCreate(
                [
                    'salon_id' => $salonId,
                    'product_id' => $productId,
                    'location_id' => $locationId
                ],
                ['qty' => 0]
            );
            
            $item->qty += $delta;
            if ($item->qty < 0) {
                $item->qty = 0; // clamp; optional: throw exception
            }
            $item->save();

            return StockMovement::create([
                'salon_id' => $salonId,
                'product_id' => $productId,
                'location_id' => $locationId,
                'type' => $type,
                'delta' => $delta,
                'meta' => $meta,
                'moved_at' => now(),
            ]);
        });
    }
}