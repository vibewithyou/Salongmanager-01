<?php

namespace App\Services\Inventory;

use Illuminate\Support\Facades\DB;

class PoNumber 
{
    public static function next(int $salonId): string 
    {
        return DB::transaction(function() use ($salonId) {
            $year = now()->year;
            $key = "po_seq_{$salonId}_{$year}";
            
            // TODO: Use invoice_sequences table with type='po' if counters table doesn't exist
            $row = DB::table('counters')->lockForUpdate()->where('key', $key)->first();
            
            if (!$row) {
                DB::table('counters')->insert(['key' => $key, 'value' => 0]);
                $row = (object)['value' => 0];
            }
            
            $n = $row->value + 1;
            DB::table('counters')->where('key', $key)->update(['value' => $n]);
            
            return sprintf('PO-%d-%06d', $year, $n);
        });
    }
}