<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class TenantRequired
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        // Skip for non-API routes
        if (!$request->is('api/*')) {
            return $next($request);
        }

        // Whitelist public/infra routes
        $exempt = ['api/v1/health', 'up', 'login', 'register', 'password'];
        if ($request->is($exempt)) {
            return $next($request);
        }

        // Check if tenant is already resolved (from TenantResolveMiddleware)
        if (app()->has('tenant_id')) {
            return $next($request);
        }

        // Check if user is authenticated
        if (!Auth::check()) {
            return response()->json([
                'message' => 'Authentication required',
                'error' => 'UNAUTHENTICATED'
            ], 401);
        }

        $user = Auth::user();
        
        // Check if user has a salon_id
        if (!$user->salon_id) {
            return response()->json([
                'message' => 'Tenant context required',
                'error' => 'TENANT_REQUIRED'
            ], 403);
        }

        // Set tenant context for the request
        $request->merge(['tenant_id' => $user->salon_id]);
        
        // Add tenant context to the app container
        app()->instance('tenant_id', $user->salon_id);

        return $next($request);
    }
}
