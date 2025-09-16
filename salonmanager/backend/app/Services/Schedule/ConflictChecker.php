<?php

namespace App\Services\Schedule;

use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ConflictChecker
{
    public static function hasBookingConflict(int $salonId, int $userId, Carbon $from, Carbon $to): bool
    {
        return DB::table('bookings')
            ->where('salon_id', $salonId)
            ->where('stylist_id', $userId)
            ->whereIn('status', ['pending', 'confirmed'])
            ->where(function ($q) use ($from, $to) {
                $q->whereBetween('start_at', [$from, $to])
                    ->orWhereBetween('end_at', [$from, $to])
                    ->orWhere(function ($x) use ($from, $to) {
                        $x->where('start_at', '<=', $from)->where('end_at', '>=', $to);
                    });
            })->exists();
    }

    public static function hasAbsenceConflict(int $salonId, int $userId, Carbon $from, Carbon $to): bool
    {
        return DB::table('absences')
            ->where('salon_id', $salonId)
            ->where('user_id', $userId)
            ->where('status', 'approved')
            ->where(function ($q) use ($from, $to) {
                $q->whereBetween('start_at', [$from, $to])
                    ->orWhereBetween('end_at', [$from, $to])
                    ->orWhere(function ($x) use ($from, $to) {
                        $x->where('start_at', '<=', $from)->where('end_at', '>=', $to);
                    });
            })->exists();
    }
}
