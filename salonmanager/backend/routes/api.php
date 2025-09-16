<?php
/*
 |--------------------------------------------------------------
 | API Routes (v1)
 | Purpose: Provide versioned API endpoints under /api/v1
 | Notes: Healthcheck only for skeleton. Add modules later.
 |--------------------------------------------------------------
*/

use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::get('/health', function () {
        return response()->json([
            'status' => 'ok',
            'version' => 'v1',
        ]);
    });
});

