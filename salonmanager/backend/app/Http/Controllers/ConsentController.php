<?php

namespace App\Http\Controllers;

use App\Models\Consent;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ConsentController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'type' => 'required|string|max:255',
            'accepted' => 'required|boolean',
        ]);

        $consent = Consent::create([
            'salon_id' => app('tenant')?->id,
            'user_id' => auth()->id(),
            'type' => $validated['type'],
            'accepted' => $validated['accepted'],
            'ua' => $request->userAgent(),
        ]);

        return response()->json([
            'message' => 'Consent recorded successfully',
            'consent' => $consent,
        ], 201);
    }
}
