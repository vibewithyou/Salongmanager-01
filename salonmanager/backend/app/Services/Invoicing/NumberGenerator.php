<?php

namespace App\Services\Invoicing;

use App\Models\InvoiceSequence;
use App\Models\Salon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class NumberGenerator
{
    public static function nextForSalon(int $salonId): string
    {
        return DB::transaction(function () use ($salonId) {
            $year = now()->year;
            $seq = InvoiceSequence::lockForUpdate()->firstOrCreate(
                ['salon_id' => $salonId, 'year' => $year],
                ['current_no' => 0]
            );
            
            $seq->current_no = ($seq->current_no ?? 0) + 1;
            $seq->save();
            
            $salon = Salon::findOrFail($salonId);
            $slug = Str::upper(Str::slug($salon->slug));
            
            return sprintf('%d-%s-%06d', $year, $slug, $seq->current_no);
        });
    }
}