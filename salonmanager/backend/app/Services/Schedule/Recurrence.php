<?php

namespace App\Services\Schedule;

use Carbon\Carbon;
use App\Models\Shift;

class Recurrence
{
    /**
     * Expandiert eine wiederkehrende Schicht in konkrete Instanzen im Zeitraum.
     * Very lite RRULE: FREQ=WEEKLY;BYDAY=MO,TU,...;UNTIL=YYYY-MM-DD
     */
    public static function expand(Shift $s, Carbon $from, Carbon $to): array
    {
        if (!$s->rrule) {
            return [[$s->start_at, $s->end_at]];
        }

        $params = collect(explode(';', $s->rrule))->mapWithKeys(function ($p) {
            [$k, $v] = array_pad(explode('=', $p, 2), 2, null);
            return [strtoupper($k) => $v];
        });

        $freq = $params->get('FREQ', 'WEEKLY');
        $byday = collect(explode(',', (string) $params->get('BYDAY', '')))->filter();
        $until = $params->has('UNTIL') ? Carbon::parse($params->get('UNTIL'))->endOfDay() : $to;

        $ex = collect($s->exdates ?? [])->map(fn ($d) => Carbon::parse($d)->toDateString());
        $cursor = (clone $from)->startOfDay();
        $out = [];

        while ($cursor <= $to && $cursor <= $until) {
            if ($freq === 'WEEKLY') {
                // prüfe Wochentag
                $wd = strtoupper(substr($cursor->format('D'), 0, 2)); // MO, TU ...
                if ($byday->isEmpty() || $byday->contains($wd)) {
                    $start = Carbon::parse($s->start_at)->setDate($cursor->year, $cursor->month, $cursor->day);
                    $end = Carbon::parse($s->end_at)->setDate($cursor->year, $cursor->month, $cursor->day);
                    if (!$ex->contains($start->toDateString()) && $start >= $from && $end <= $to) {
                        $out[] = [$start, $end];
                    }
                }
                $cursor->addDay();
            } else {
                break; // weitere FREQs nicht implementiert
            }
        }
        return $out;
    }
}
