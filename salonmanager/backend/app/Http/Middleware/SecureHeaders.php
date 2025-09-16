<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class SecureHeaders
{
  public function handle(Request $request, Closure $next): Response
  {
    $res = $next($request);
    $host = parse_url(config('app.url'), PHP_URL_HOST) ?: 'salongmanager.app';

    $csp = "default-src 'self'; img-src 'self' data: blob:; media-src 'self' blob:; ".
           "script-src 'self'; style-src 'self' 'unsafe-inline'; font-src 'self' data:; ".
           "connect-src 'self' https://$host; frame-ancestors 'none'";

    $res->headers->set('Content-Security-Policy', $csp);
    $res->headers->set('X-Content-Type-Options', 'nosniff');
    $res->headers->set('X-Frame-Options', 'DENY');
    $res->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
    $res->headers->set('Permissions-Policy', 'camera=(), geolocation=(), microphone=()');
    $res->headers->set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');

    return $res;
  }
}
