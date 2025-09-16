<?php
namespace App\Http\Middleware;

use Illuminate\Routing\Middleware\ThrottleRequests;

class ScopeRateLimit extends ThrottleRequests
{
  protected function resolveRequestSignature($request)
  {
    $user = $request->user();
    $scope = $request->header('X-Api-Scope') ?? ($user?->rolesInTenant(app('tenant')->id)[0] ?? 'guest');
    return sha1($scope.'|'.$request->ip().'|'.$request->path());
  }
}
