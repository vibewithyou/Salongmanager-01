<?php
namespace App\Support\Idempotency;

use Illuminate\Support\Facades\DB;

class Idempotency {
  public static function once(string $key, string $scope, \Closure $cb) {
    return DB::transaction(function() use($key,$scope,$cb) {
      $exists = DB::table('idempotency_keys')->where('key',$key)->lockForUpdate()->first();
      if ($exists) return ['ok'=>false,'skipped'=>true];
      DB::table('idempotency_keys')->insert(['key'=>$key,'scope'=>$scope,'created_at'=>now(),'updated_at'=>now()]);
      $res = $cb();
      return ['ok'=>true,'result'=>$res];
    }, 3);
  }
}
