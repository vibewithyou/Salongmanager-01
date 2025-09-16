<?php

namespace App\Http\Controllers\Gallery;

use App\Http\Controllers\Controller;
use App\Models\GalleryAlbum;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class GalleryAlbumController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = GalleryAlbum::query()
            ->where('salon_id', app('tenant')->id);

        // Filter by visibility if user is not authenticated
        if (!auth()->check()) {
            $query->where('visibility', 'public');
        }

        $albums = $query->with(['creator', 'photos' => function ($q) {
            $q->approved()->latest();
        }])->latest()->get();

        return response()->json($albums);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'visibility' => ['required', 'in:public,private,unlisted'],
        ]);

        $album = GalleryAlbum::create([
            ...$data,
            'salon_id' => app('tenant')->id,
            'created_by' => auth()->id(),
        ]);

        return response()->json($album->load('creator'), 201);
    }

    public function show(GalleryAlbum $album): JsonResponse
    {
        $this->authorize('view', $album);

        return response()->json($album->load(['creator', 'photos' => function ($q) {
            $q->approved()->latest();
        }]));
    }

    public function update(Request $request, GalleryAlbum $album): JsonResponse
    {
        $this->authorize('update', $album);

        $data = $request->validate([
            'title' => ['sometimes', 'string', 'max:255'],
            'visibility' => ['sometimes', 'in:public,private,unlisted'],
        ]);

        $album->update($data);

        return response()->json($album->load('creator'));
    }

    public function destroy(GalleryAlbum $album): JsonResponse
    {
        $this->authorize('delete', $album);

        $album->delete();

        return response()->json(['message' => 'Album deleted successfully']);
    }
}
