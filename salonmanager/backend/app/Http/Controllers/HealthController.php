<?php

namespace App\Http\Controllers;

class HealthController extends Controller
{
    public function index()
    {
        return response()->json([
            'status'  => 'ok',
            'version' => 'v1',
            'time'    => now()->toISOString(),
        ]);
    }
}