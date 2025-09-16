<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    /** SPA login using web guard & Sanctum cookie */
    public function login(Request $request)
    {
        $data = $request->validate([
            'email'    => ['required','email'],
            'password' => ['required'],
        ]);

        if (!Auth::attempt($data, true)) {
            return response()->json(['message' => 'Invalid credentials'], 422);
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

    /** PAT for mobile clients */
    public function token(Request $request)
    {
        $data = $request->validate([
            'email'    => ['required','email'],
            'password' => ['required'],
            'scopes'   => ['array'],
        ]);

        if (!Auth::attempt(['email'=>$data['email'], 'password'=>$data['password']])) {
            return response()->json(['message' => 'Invalid credentials'], 422);
        }

        /** @var \App\Models\User $user */
        $user = Auth::user();
        $tokenName = 'mobile-token-'.now()->format('YmdHis');
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