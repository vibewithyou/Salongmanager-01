<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HealthController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Salon\ProfileController;
use App\Http\Controllers\Salon\BlockController;
use App\Http\Controllers\BookingController;

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

    // Salon profile and content blocks
    // public read
    Route::get('/salon/profile', [ProfileController::class, 'show'])->middleware('tenant.required');
    Route::get('/salon/blocks',  [BlockController::class, 'index'])->middleware('tenant.required');

    // protected write
    Route::middleware(['auth:sanctum','tenant.required','role:salon_owner,salon_manager'])->group(function () {
        Route::put('/salon/profile',  [ProfileController::class, 'update']);
        Route::post('/salon/blocks',  [BlockController::class, 'store']);
        Route::get('/salon/blocks/{block}', [BlockController::class, 'show']);
        Route::put('/salon/blocks/{block}', [BlockController::class, 'update']);
        Route::delete('/salon/blocks/{block}', [BlockController::class, 'destroy']);
    });

    // Booking routes
    Route::middleware(['auth:sanctum', 'tenant.required'])->prefix('booking')->group(function () {
        Route::get('/', [BookingController::class, 'index']);
        Route::post('/', [BookingController::class, 'store'])->middleware('role:customer');
        Route::post('/{booking}/confirm', [BookingController::class, 'confirm'])->middleware('role:stylist,salon_owner,salon_manager');
        Route::post('/{booking}/decline', [BookingController::class, 'decline'])->middleware('role:stylist,salon_owner,salon_manager');
        Route::post('/{booking}/cancel', [BookingController::class, 'cancel'])->middleware('role:customer,salon_owner,salon_manager');
    });

    // Services and Stylists routes (for booking wizard)
    Route::middleware(['auth:sanctum', 'tenant.required'])->group(function () {
        Route::get('/services', [BookingController::class, 'services']);
        Route::get('/stylists', [BookingController::class, 'stylists']);
    });
});