<?php
namespace App\Services\Billing;

use Illuminate\Support\Facades\DB;

class InvoiceNumberService {
  public static function nextNumber(int $salonId): string {
    $year = (int)date('Y');
    return DB::transaction(function() use($salonId,$year){
      $seq = DB::table('invoice_sequences')->where(compact('salonId','year'))
              ->lockForUpdate()->first();
      if (!$seq) {
        DB::table('invoice_sequences')->insert(['salon_id'=>$salonId,'year'=>$year,'current_no'=>0,'created_at'=>now(),'updated_at'=>now()]);
        $seq = DB::table('invoice_sequences')->where(compact('salonId','year'))->lockForUpdate()->first();
      }
      $next = ((int)$seq->current_no) + 1;
      DB::table('invoice_sequences')->where('id',$seq->id)->update(['current_no'=>$next,'updated_at'=>now()]);
      // Format: SM-{SALON}-{YEAR}-{000001}
      return sprintf('SM-%d-%d-%06d', $salonId, $year, $next);
    }, 3);
  }
}
