<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HealthController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Salon\ProfileController;
use App\Http\Controllers\Salon\BlockController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\Staff\ShiftController;
use App\Http\Controllers\Staff\AbsenceController;

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

    // Staff scheduling routes
    Route::prefix('staff')->middleware(['auth:sanctum', 'tenant.required'])->group(function () {
        // Shifts
        Route::get('/shifts', [ShiftController::class, 'index'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::post('/shifts', [ShiftController::class, 'store'])->middleware('role:salon_owner,salon_manager');
        Route::put('/shifts/{shift}', [ShiftController::class, 'update'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::delete('/shifts/{shift}', [ShiftController::class, 'destroy'])->middleware('role:salon_owner,salon_manager');

        // Drag/Resize helpers
        Route::post('/shifts/{shift}/move', [ShiftController::class, 'move'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::post('/shifts/{shift}/resize', [ShiftController::class, 'resize'])->middleware('role:salon_owner,salon_manager,stylist');

        // Absences
        Route::get('/absences', [AbsenceController::class, 'index'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::post('/absences', [AbsenceController::class, 'store'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::put('/absences/{absence}', [AbsenceController::class, 'update'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::delete('/absences/{absence}', [AbsenceController::class, 'destroy'])->middleware('role:salon_owner,salon_manager');
        Route::post('/absences/{absence}/approve', [AbsenceController::class, 'approve'])->middleware('role:salon_owner,salon_manager');
    });
});