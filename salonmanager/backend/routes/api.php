<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HealthController;
use App\Http\Controllers\AuthController;

Route::prefix('v1')->group(function () {
    Route::get('/health', [HealthController::class, 'index']);

    Route::prefix('auth')->group(function () {
        Route::post('/login', [AuthController::class, 'login']);           // SPA Cookie (Sanctum)
        Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
        Route::post('/token', [AuthController::class, 'token']);           // Personal Access Token (PAT)
        Route::get('/me', [AuthController::class, 'me'])->middleware('auth:sanctum');
    });
});