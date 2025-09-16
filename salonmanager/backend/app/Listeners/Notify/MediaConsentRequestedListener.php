<?php
namespace App\Listeners\Notify;

use App\Models\{Booking, Invoice, MediaFile, User};
use App\Services\Notify\Notifier;

class MediaConsentRequestedListener {
  public function handle($event): void {
    $f = MediaFile::with([])->find($event->mediaFileId);
    if (!$f) return;
    // notify salon managers
    $managers = \App\Models\User::whereHas('roles', fn($q)=>$q->whereIn('name',['salon_owner','salon_manager']))
      ->where('salon_id', $f->salon_id)->get();
    foreach ($managers as $u) {
      Notifier::send([
        'salon_id'=>$f->salon_id, 'event'=>'media.consent.requested', 'user'=>$u,
        'data'=>['file'=>['id'=>$f->id,'path'=>$f->path],'salon'=>['name'=>app('tenant')->name ?? 'Salon']],
        'ref'=>['type'=>'MediaFile','id'=>$f->id]
      ]);
    }
  }
}