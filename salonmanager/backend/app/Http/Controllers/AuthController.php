<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;
use Laravel\Fortify\TwoFactorAuthenticatable;
use PragmaRX\Google2FA\Google2FA;

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

    /** Enable 2FA - generate secret and QR code */
    public function enable2FA(Request $request)
    {
        $user = $request->user();
        
        if ($user->two_factor_secret) {
            return response()->json(['message' => '2FA already enabled'], 400);
        }

        $google2fa = new Google2FA();
        $secretKey = $google2fa->generateSecretKey();
        
        $user->forceFill([
            'two_factor_secret' => encrypt($secretKey),
        ])->save();

        $qrCodeUrl = $google2fa->getQRCodeUrl(
            config('app.name'),
            $user->email,
            $secretKey
        );

        return response()->json([
            'secret' => $secretKey,
            'qr_code_url' => $qrCodeUrl,
        ]);
    }

    /** Confirm 2FA - verify code and enable */
    public function confirm2FA(Request $request)
    {
        $request->validate([
            'code' => ['required', 'string', 'size:6'],
        ]);

        $user = $request->user();
        $google2fa = new Google2FA();
        
        $secretKey = decrypt($user->two_factor_secret);
        
        if (!$google2fa->verifyKey($secretKey, $request->code)) {
            return response()->json(['message' => 'Invalid verification code'], 422);
        }

        $user->forceFill([
            'two_factor_confirmed_at' => now(),
        ])->save();

        return response()->json(['message' => '2FA enabled successfully']);
    }

    /** Disable 2FA */
    public function disable2FA(Request $request)
    {
        $user = $request->user();
        
        $user->forceFill([
            'two_factor_secret' => null,
            'two_factor_confirmed_at' => null,
        ])->save();

        return response()->json(['message' => '2FA disabled successfully']);
    }
}