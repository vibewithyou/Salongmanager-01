<?php
namespace App\Http\Controllers\Notify;

use App\Http\Controllers\Controller;
use App\Http\Requests\Notify\WebhookUpsertRequest;
use App\Models\Webhook;

class WebhooksController extends Controller {
  public function index() {
    $rows = Webhook::where('salon_id', app('tenant')->id)->orderBy('event')->get();
    return response()->json(['items'=>$rows]);
  }
  public function store(WebhookUpsertRequest $r) {
    $w = Webhook::create(['salon_id'=>app('tenant')->id] + $r->validated());
    return response()->json(['webhook'=>$w],201);
  }
  public function update(WebhookUpsertRequest $r, Webhook $webhook) {
    $webhook->update($r->validated());
    return response()->json(['webhook'=>$webhook]);
  }
  public function destroy(Webhook $webhook) {
    $webhook->delete();
    return response()->json(['ok'=>true]);
  }
}