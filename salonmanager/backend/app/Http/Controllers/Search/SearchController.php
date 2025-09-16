<?php

namespace App\Http\Controllers\Search;

use App\Http\Controllers\Controller;
use App\Http\Requests\Search\SalonSearchRequest;
use App\Http\Requests\Search\AvailabilityRequest;
use App\Models\Salon;
use App\Models\Service;
use App\Models\Booking;
use App\Models\Shift;
use App\Models\OpeningHour;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    /** GET /api/v1/search/salons */
    public function salons(SalonSearchRequest $req)
    {
        $v = $req->validated();
        $lat = $v['lat'] ?? null;
        $lng = $v['lng'] ?? null;
        $radiusKm = $v['radius_km'] ?? null;
        $per = $v['per_page'] ?? 20;
        $sort = $v['sort'] ?? ($lat && $lng ? 'distance' : 'name');

        $q = Salon::query()->publicFields();

        // Textsuche: name, city, tags
        if (!empty($v['q'])) {
            $term = '%'.str_replace(' ', '%', $v['q']).'%';
            $q->where(function($w) use ($term) {
                $w->where('name','like',$term)
                  ->orWhere('city','like',$term)
                  ->orWhereRaw("JSON_SEARCH(tags, 'one', ? ) IS NOT NULL", [trim($term,'%')]);
            });
        }

        // Service-Filter (einfach: Salon hat mindestens eine Service-ID → via exists)
        if (!empty($v['service_id'])) {
            $sid = (int)$v['service_id'];
            $q->whereExists(function($sq) use($sid){
                $sq->select(DB::raw(1))
                    ->from('services')
                    ->whereColumn('services.salon_id','salons.id')
                    ->where('services.id', $sid);
            });
        }

        // Open now: einfache Prüfung anhand Öffnungszeiten des Wochentags
        if (!empty($v['open_now'])) {
            $now = Carbon::now();
            $weekday = (int)$now->dayOfWeekIso; // 1..7
            $time = $now->format('H:i:s');
            $q->whereExists(function($sq) use ($weekday, $time) {
                $sq->select(DB::raw(1))->from('opening_hours')
                   ->whereColumn('opening_hours.salon_id','salons.id')
                   ->where('weekday', $weekday)
                   ->where('closed', false)
                   ->where('open_time','<=',$time)
                   ->where('close_time','>=',$time);
            });
        }

        // Distanzberechnung & Radius
        if ($lat !== null && $lng !== null) {
            // ST_Distance_Sphere expects POINT(lng,lat). We stored SRID 4326.
            $point = "ST_SRID(POINT($lng,$lat),4326)";
            $q->addSelect(DB::raw("ST_Distance_Sphere(location, $point)/1000 as distance_km"));

            if ($radiusKm !== null) {
                $q->whereRaw("ST_Distance_Sphere(location, $point) <= ?", [ $radiusKm * 1000 ]);
            }

            if ($sort === 'distance') $q->orderBy('distance_km');
        }

        if ($sort === 'name') $q->orderBy('name');

        $result = $q->paginate($per);

        return response()->json([
            'items' => $result->items(),
            'pagination' => [
                'current_page' => $result->currentPage(),
                'per_page' => $result->perPage(),
                'total' => $result->total(),
                'next_page' => $result->nextPageUrl() ? $result->currentPage()+1 : null,
            ],
        ]);
    }

    /** GET /api/v1/search/availability */
    public function availability(AvailabilityRequest $req)
    {
        $v = $req->validated();
        $salonId = $v['salon_id'];
        $service = Service::where('salon_id',$salonId)->findOrFail($v['service_id']);
        $from = !empty($v['from']) ? Carbon::parse($v['from']) : Carbon::now();
        $to   = !empty($v['to'])   ? Carbon::parse($v['to'])   : (clone $from)->addDays(14);
        $limit = $v['limit'] ?? 3;

        // Sehr einfache Slot-Berechnung:
        // - Nutze Shifts der Stylisten in dem Zeitraum
        // - Subtrahiere überlappende Bookings
        // - Fülle mit Slotdauer = service.base_duration
        $slots = [];
        $shiftQ = Shift::query()
            ->where('salon_id',$salonId)
            ->whereBetween('start_at', [$from->copy()->startOfDay(), $to->copy()->endOfDay()]);
        foreach ($shiftQ->get(['id','stylist_id','start_at','end_at']) as $shift) {
            $cursor = $shift->start_at->copy();
            while ($cursor->addMinutes(0) < $shift->end_at) {
                $slotStart = $cursor->copy();
                $slotEnd = $slotStart->copy()->addMinutes($service->base_duration);
                if ($slotEnd > $shift->end_at) break;

                // Booking-Kollision prüfen
                $overlap = Booking::query()
                    ->where('salon_id',$salonId)
                    ->where(function($w) use ($slotStart,$slotEnd) {
                        $w->whereBetween('start_at', [$slotStart, $slotEnd->copy()->subMinute()])
                          ->orWhereBetween('end_at', [$slotStart->copy()->addMinute(), $slotEnd])
                          ->orWhere(function($q) use ($slotStart,$slotEnd){
                              $q->where('start_at','<=',$slotStart)->where('end_at','>=',$slotEnd);
                          });
                    })->exists();

                if (!$overlap) {
                    $slots[] = [
                        'stylist_id' => $shift->stylist_id,
                        'start_at'   => $slotStart->toIso8601String(),
                        'end_at'     => $slotEnd->toIso8601String(),
                    ];
                    if (count($slots) >= $limit) break 2;
                }

                // Schrittweite: 15min Raster (oder exakt base_duration; hier 15min)
                $cursor = $cursor->addMinutes(15);
            }
        }

        return response()->json(['slots'=>$slots]);
    }
}