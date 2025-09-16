<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

abstract class Controller
{
    /**
     * Get pagination per page with sensible defaults and limits
     */
    protected function perPage(Request $request, int $default = 20, int $max = 100): int
    {
        return min(max((int)$request->integer('per_page', $default), 1), $max);
    }
}