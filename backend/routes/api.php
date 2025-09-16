<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\GdprController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// GDPR Routes
Route::prefix('v1/gdpr')->middleware(['auth:sanctum', 'tenant.required'])->group(function () {
    Route::post('/export', [GdprController::class, 'requestExport']);
    Route::post('/delete', [GdprController::class, 'requestDelete']);
    
    // Admin only route
    Route::middleware('role:salon_owner,platform_admin')
        ->post('/delete/{gdprRequest}/confirm', [GdprController::class, 'confirmDelete']);
});