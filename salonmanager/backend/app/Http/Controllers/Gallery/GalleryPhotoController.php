<?php

namespace App\Http\Controllers\Gallery;

use App\Http\Controllers\Controller;
use App\Models\GalleryPhoto;
use App\Models\GalleryAlbum;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class GalleryPhotoController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = GalleryPhoto::query()
            ->where('salon_id', app('tenant')->id)
            ->with(['album', 'customer', 'creator']);

        // Filter by album if specified
        if ($request->has('album_id')) {
            $query->where('album_id', $request->album_id);
        }

        // Filter by approval status
        if ($request->boolean('approved')) {
            $query->approved();
        }

        // Filter by before/after group
        if ($request->has('before_after_group')) {
            $query->where('before_after_group', $request->before_after_group);
        }

        // For public access, only show approved photos
        if (!auth()->check()) {
            $query->approved()->public();
        }

        $photos = $query->latest()->paginate(20);

        return response()->json($photos);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'album_id' => ['nullable', 'exists:gallery_albums,id'],
            'customer_id' => ['nullable', 'exists:customer_profiles,id'],
            'image' => ['required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:10240'], // 10MB max
            'before_after_group' => ['nullable', 'uuid'],
            'consent_given' => ['required', 'boolean'],
        ]);

        if (!$data['consent_given']) {
            return response()->json(['message' => 'Consent is required to upload photos'], 422);
        }

        // Generate before/after group if not provided
        if (!$data['before_after_group']) {
            $data['before_after_group'] = Str::uuid();
        }

        // Store the image
        $file = $request->file('image');
        $path = $file->store('gallery/photos', 'public');

        // Create photo record
        $photo = GalleryPhoto::create([
            'salon_id' => app('tenant')->id,
            'album_id' => $data['album_id'],
            'customer_id' => $data['customer_id'],
            'path' => $path,
            'before_after_group' => $data['before_after_group'],
            'created_by' => auth()->id(),
        ]);

        // Create image derivatives
        dispatch(new \App\Jobs\CreateImageDerivativesJob($photo));

        // Create consent record
        \App\Models\GalleryConsent::create([
            'salon_id' => app('tenant')->id,
            'customer_id' => $data['customer_id'],
            'photo_id' => $photo->id,
            'status' => 'approved',
            'note' => 'Consent given during upload',
            'created_by' => auth()->id(),
        ]);

        return response()->json($photo->load(['album', 'customer', 'creator']), 201);
    }

    public function show(GalleryPhoto $photo): JsonResponse
    {
        $this->authorize('view', $photo);

        return response()->json($photo->load(['album', 'customer', 'creator', 'consents']));
    }

    public function moderate(Request $request, GalleryPhoto $photo): JsonResponse
    {
        $this->authorize('moderate', $photo);

        $data = $request->validate([
            'action' => ['required', 'in:approve,reject'],
            'note' => ['nullable', 'string', 'max:1000'],
        ]);

        if ($data['action'] === 'approve') {
            $photo->update([
                'approved_at' => now(),
                'rejected_at' => null,
            ]);
        } else {
            $photo->update([
                'approved_at' => null,
                'rejected_at' => now(),
            ]);
        }

        return response()->json([
            'message' => 'Photo ' . $data['action'] . 'd successfully',
            'photo' => $photo->fresh()
        ]);
    }

    public function destroy(GalleryPhoto $photo): JsonResponse
    {
        $this->authorize('delete', $photo);

        // Delete the file
        Storage::disk('public')->delete($photo->path);

        // Delete variants
        if ($photo->variants) {
            foreach ($photo->variants as $variant) {
                Storage::disk('public')->delete($variant['path'] ?? '');
            }
        }

        $photo->delete();

        return response()->json(['message' => 'Photo deleted successfully']);
    }
}
