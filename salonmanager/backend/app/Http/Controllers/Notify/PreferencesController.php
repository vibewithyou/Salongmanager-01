<?php
namespace App\Http\Controllers\Notify;

use App\Http\Controllers\Controller;
use App\Http\Requests\Notify\UpdatePrefsRequest;
use App\Models\NotificationSetting;
use Illuminate\Http\Request;

class PreferencesController extends Controller {
  public function index(Request $r) {
    $rows = NotificationSetting::where('salon_id', app('tenant')->id)->where('user_id',$r->user()->id)->get();
    return response()->json(['items'=>$rows]);
  }
  public function update(UpdatePrefsRequest $r) {
    $salonId = app('tenant')->id; $uid = $r->user()->id;
    foreach ($r->validated()['items'] as $it) {
      NotificationSetting::updateOrCreate(
        ['salon_id'=>$salonId,'user_id'=>$uid,'event'=>$it['event'],'channel'=>$it['channel']],
        ['enabled'=>$it['enabled']]
      );
    }
    return response()->json(['ok'=>true]);
  }
}