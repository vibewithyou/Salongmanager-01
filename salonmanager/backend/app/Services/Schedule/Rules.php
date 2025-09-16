<?php

namespace App\Services\Schedule;

use App\Models\WorkRule;
use Carbon\Carbon;

class Rules
{
    public static function violatesDailyHours(int $salonId, \DateTimeInterface $start, \DateTimeInterface $end): bool
    {
        $rule = WorkRule::where('salon_id', $salonId)->first();
        if (!$rule) {
            return false;
        }
        $hours = (Carbon::parse($start)->diffInMinutes($end)) / 60.0;
        return $hours > $rule->max_hours_per_day;
    }
}
