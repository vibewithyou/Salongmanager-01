<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class EnsureTwoFactorConfirmed
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = Auth::user();
        
        if (!$user) {
            return $next($request);
        }

        // Get required roles from environment
        $requiredRoles = explode(',', env('TWO_FA_REQUIRED_ROLES', 'owner,platform_admin,salon_owner'));
        $requiredRoles = array_map('trim', $requiredRoles);

        // Check if user has any of the required roles
        $userRoles = $user->roles->pluck('name')->toArray();
        $hasRequiredRole = !empty(array_intersect($userRoles, $requiredRoles));

        if ($hasRequiredRole && !$user->two_factor_confirmed_at) {
            return response()->json([
                'message' => 'Two-factor authentication is required for your role.',
                'requires_2fa' => true,
                'two_factor_available' => !is_null($user->two_factor_secret),
            ], 403);
        }

        return $next($request);
    }
}
