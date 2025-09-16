<?php
namespace App\Listeners\Notify;

use App\Models\{Booking, Invoice, MediaFile, User};
use App\Services\Notify\Notifier;

class InvoicePaidListener {
  public function handle($event): void {
    $inv = \App\Models\Invoice::with('customer')->find($event->invoiceId);
    if (!$inv || !$inv->customer) return;
    $data = [
      'user'=> ['name'=>$inv->customer->name],
      'invoice'=> ['number'=>$inv->number,'total'=>$inv->total_gross],
      'salon'=> ['name'=>app('tenant')->name ?? 'Salon']
    ];
    Notifier::send([
      'salon_id'=>$inv->salon_id,'event'=>'pos.invoice.paid','user'=>$inv->customer,'data'=>$data,
      'ref'=>['type'=>'Invoice','id'=>$inv->id]
    ]);
  }
}