<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\Salon;

class TenantResolveMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $host = $request->getHost(); // e.g., foo.salongmanager.app
        $tenantSlug = null;

        if (str_ends_with($host, 'salongmanager.app')) {
            $parts = explode('.', $host);
            if (count($parts) > 2) {
                $tenantSlug = $parts[0]; // subdomain
            }
        }

        $tenantSlug = $request->header('X-Salon-Slug', $tenantSlug);
        $tenantId   = $request->header('X-Salon-ID');

        $salon = null;
        if ($tenantId) {
            $salon = Salon::query()->where('id', $tenantId)->first();
        } elseif ($tenantSlug) {
            $salon = Salon::query()->where('slug', $tenantSlug)->first();
        }

        if (!$salon) {
            return response()->json(['error' => 'TENANT_NOT_RESOLVED'], 400);
        }

        app()->instance('tenant', $salon);

        return $next($request);
    }
}