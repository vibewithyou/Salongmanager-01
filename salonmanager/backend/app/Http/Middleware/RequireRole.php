<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RequireRole
{
  public function handle(Request $request, Closure $next, ...$roleNames): Response
  {
    $user = $request->user();
    if (!$user) abort(401);
    if ($user->hasAnyRole($roleNames)) return $next($request);
    abort(403, 'Insufficient role');
  }
}