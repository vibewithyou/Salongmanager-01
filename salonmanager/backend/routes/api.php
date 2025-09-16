<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HealthController;
use App\Http\Controllers\AuthController;

Route::prefix('v1')->group(function () {
    Route::get('/health', [HealthController::class, 'index']);

    Route::prefix('auth')->group(function () {
        // SPA flow
        Route::get('/csrf', [AuthController::class, 'csrf']); // CSRF cookie helper
        Route::post('/login', [AuthController::class, 'login']); // Sanctum cookie session
        Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
        Route::get('/me', [AuthController::class, 'me'])->middleware('auth:sanctum');

        // Mobile/PAT flow
        Route::post('/token', [AuthController::class, 'token']);
    });
});