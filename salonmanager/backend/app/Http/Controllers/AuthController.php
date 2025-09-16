<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AuthController extends Controller
{
    /** Issue CSRF cookie for SPA (Sanctum expects /sanctum/csrf-cookie by default; we provide alias) */
    public function csrf(Request $request)
    {
        // Laravel Sanctum already sets the XSRF-TOKEN cookie at /sanctum/csrf-cookie.
        // This endpoint proxies it for convenience (/api/v1/auth/csrf).
        return response()->json(['ok' => true])->withCookie(
            cookie()->forever('XSRF-TOKEN', csrf_token(), null, null, null, false, false)
        );
    }

    /** SPA login using web guard & Sanctum cookie */
    public function login(Request $request)
    {
        $data = $request->validate([
            'email'    => ['required','email'],
            'password' => ['required','string'],
            // 'remember' => ['boolean'], // optional
        ]);

        // CSRF must be present for SPA cookie login (EnsureFrontendRequestsAreStateful)
        if (!$request->hasHeader('X-XSRF-TOKEN') && !$request->cookie('XSRF-TOKEN')) {
            return response()->json(['message' => 'CSRF token missing'], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        if (!Auth::attempt($data, true)) {
            return response()->json(['message' => 'Invalid credentials'], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $request->session()->regenerate();

        return response()->json(['ok' => true]);
    }

    /** SPA logout */
    public function logout(Request $request)
    {
        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return response()->json(['ok' => true]);
    }

    /** PAT for mobile clients (Bearer) */
    public function token(Request $request)
    {
        $data = $request->validate([
            'email'    => ['required','email'],
            'password' => ['required','string'],
            'scopes'   => ['array'],
        ]);

        if (!Auth::attempt(['email' => $data['email'], 'password' => $data['password']])) {
            return response()->json(['message' => 'Invalid credentials'], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();
        $tokenName = 'pat-'.now()->format('YmdHis');
        $token = $user->createToken($tokenName, $data['scopes'] ?? [])->plainTextToken;

        return response()->json(['token' => $token, 'type' => 'Bearer']);
    }

    /** whoami */
    public function me(Request $request)
    {
        return response()->json([
            'user'   => $request->user(),
            'tenant' => app()->bound('tenant') ? app('tenant') : null,
        ]);
    }
}