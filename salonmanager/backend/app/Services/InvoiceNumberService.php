<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use App\Models\InvoiceSequence;

class InvoiceNumberService
{
    /**
     * Generate the next invoice number for a salon and year
     */
    public static function nextNumber(int $salonId, int $year = null): string
    {
        $year = $year ?? date('Y');
        
        return DB::transaction(function () use ($salonId, $year) {
            // Lock the sequence row for update
            $sequence = InvoiceSequence::where('salon_id', $salonId)
                ->where('year', $year)
                ->lockForUpdate()
                ->first();
            
            if (!$sequence) {
                $sequence = InvoiceSequence::create([
                    'salon_id' => $salonId,
                    'year' => $year,
                    'current_no' => 0
                ]);
            }
            
            // Increment and get next number
            $sequence->increment('current_no');
            $nextNumber = $sequence->current_no;
            
            // Format: SM-{salon_id}-{year}-{000001}
            return sprintf('SM-%d-%d-%06d', $salonId, $year, $nextNumber);
        });
    }
    
    /**
     * Get the current sequence number for a salon and year
     */
    public static function getCurrentNumber(int $salonId, int $year = null): int
    {
        $year = $year ?? date('Y');
        
        $sequence = InvoiceSequence::where('salon_id', $salonId)
            ->where('year', $year)
            ->first();
            
        return $sequence ? $sequence->current_no : 0;
    }
    
    /**
     * Reset sequence for a salon and year (admin only)
     */
    public static function resetSequence(int $salonId, int $year = null): bool
    {
        $year = $year ?? date('Y');
        
        return InvoiceSequence::where('salon_id', $salonId)
            ->where('year', $year)
            ->update(['current_no' => 0]) > 0;
    }
}
