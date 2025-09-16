<?php

namespace App\Services\Booking;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class AvailabilityService
{
  /**
   * Prüft ob ein Zeitfenster für Stylist frei ist (inkl. Puffer & Abwesenheiten & Öffnungszeiten).
   */
  public static function isFree(int $salonId, int $stylistId, Carbon $start, int $durationMin, int $bufBefore=0, int $bufAfter=0): bool
  {
    $from = (clone $start)->subMinutes($bufBefore);
    $to   = (clone $start)->addMinutes($durationMin + $bufAfter);

    // Öffnungszeiten prüfen (vereinfachte Variante: Öffnungszeit-Range für Datum)
    // TODO(ASK): confirm opening hours schema/table names
    $open = DB::table('opening_hours')->where('salon_id',$salonId)
      ->where('weekday', $start->dayOfWeekIso)->first();
    if ($open && ($start->format('H:i:s') < $open->open_at || $to->format('H:i:s') > $open->close_at)) {
      return false;
    }

    // Abwesenheiten (absences)
    $conflictAbs = DB::table('absences')
      ->where('salon_id',$salonId)->where('user_id',$stylistId)
      ->where(function($q) use($from,$to){
        $q->whereBetween('start_at', [$from,$to])
          ->orWhereBetween('end_at', [$from,$to])
          ->orWhere(function($x) use($from,$to){ $x->where('start_at','<=',$from)->where('end_at','>=',$to); });
      })->exists();
    if ($conflictAbs) return false;

    // Bestehende Buchungen – harte Kollisionen inkl. Puffer
    $conflictBook = DB::table('bookings')
      ->where('salon_id',$salonId)->where('stylist_id',$stylistId)
      ->whereIn('status',['pending','confirmed'])
      ->where(function($q) use($from,$to){
        $q->whereBetween('start_at', [$from,$to])
          ->orWhereBetween('end_at', [$from,$to])
          ->orWhere(function($x) use($from,$to){ $x->where('start_at','<=',$from)->where('end_at','>=',$to); });
      })->exists();

    return !$conflictBook;
  }

  /**
   * Liefert n Alternativ-Vorschläge (Time slots) am selben Tag.
   */
  public static function suggestions(int $salonId, int $stylistId, Carbon $start, int $durationMin, int $bufBefore=0, int $bufAfter=0, int $limit=5): array
  {
    $sugs = [];
    $probe = (clone $start)->minute( (int) (floor($start->minute/15)*15) ); // auf 15er Grid
    for ($i=-8; $i<=8 && count($sugs)<$limit; $i++) {
      $slot = (clone $probe)->addMinutes($i*15);
      if (self::isFree($salonId,$stylistId,$slot,$durationMin,$bufBefore,$bufAfter)) {
        $sugs[] = $slot->toIso8601String();
      }
    }
    return $sugs;
  }
}