<?php

namespace App\Http\Controllers\Gallery;

use App\Http\Controllers\Controller;
use App\Models\GalleryConsent;
use App\Models\GalleryPhoto;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class GalleryConsentController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'photo_id' => ['nullable', 'exists:gallery_photos,id'],
            'customer_id' => ['nullable', 'exists:customer_profiles,id'],
            'status' => ['required', 'in:requested,approved,revoked'],
            'note' => ['nullable', 'string', 'max:1000'],
        ]);

        $consent = GalleryConsent::create([
            ...$data,
            'salon_id' => app('tenant')->id,
            'created_by' => auth()->id(),
        ]);

        return response()->json($consent->load(['photo', 'customer', 'creator']), 201);
    }

    public function update(Request $request, GalleryConsent $consent): JsonResponse
    {
        $this->authorize('update', $consent);

        $data = $request->validate([
            'status' => ['sometimes', 'in:requested,approved,revoked'],
            'note' => ['sometimes', 'string', 'max:1000'],
        ]);

        $consent->update($data);

        return response()->json($consent->load(['photo', 'customer', 'creator']));
    }

    public function destroy(GalleryConsent $consent): JsonResponse
    {
        $this->authorize('delete', $consent);

        $consent->delete();

        return response()->json(['message' => 'Consent deleted successfully']);
    }
}
