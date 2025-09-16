<?php

namespace App\Http\Controllers;

use App\Models\Shift;
use App\Services\Schedule\Recurrence;
use Illuminate\Http\Request;
use Carbon\Carbon;

class CalendarExportController extends Controller
{
    public function ics(Request $r)
    {
        $salonId = app('tenant')->id;
        $from = Carbon::parse($r->query('from', now()->startOfMonth()));
        $to = Carbon::parse($r->query('to', now()->endOfMonth()));
        $userId = $r->query('user_id');

        $rows = Shift::where('salon_id', $salonId)
            ->when($userId, fn ($q) => $q->where('user_id', $userId))
            ->get();
            
        $lines = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//SalonManager//Schedule//EN"];
        
        foreach ($rows as $s) {
            foreach (Recurrence::expand($s, $from, $to) as [$st, $en]) {
                $lines[] = "BEGIN:VEVENT";
                $lines[] = "UID:shift-{$s->id}-" . $st->timestamp . "@salonmanager";
                $lines[] = "DTSTART:" . $st->utc()->format('Ymd\THis\Z');
                $lines[] = "DTEND:" . $en->utc()->format('Ymd\THis\Z');
                $lines[] = "SUMMARY:" . str_replace(["\r", "\n"], ' ', $s->title ?? 'Shift');
                $lines[] = "END:VEVENT";
            }
        }
        $lines[] = "END:VCALENDAR";
        
        return response(implode("\r\n", $lines), 200, ['Content-Type' => 'text/calendar; charset=utf-8']);
    }
}
