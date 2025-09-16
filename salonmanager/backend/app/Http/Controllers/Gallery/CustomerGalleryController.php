<?php

namespace App\Http\Controllers\Gallery;

use App\Http\Controllers\Controller;
use App\Models\CustomerProfile;
use App\Models\GalleryPhoto;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CustomerGalleryController extends Controller
{
    public function index(Request $request, CustomerProfile $customer): JsonResponse
    {
        // Check if user can view this customer's gallery
        $this->authorize('view', $customer);

        $query = GalleryPhoto::query()
            ->where('salon_id', app('tenant')->id)
            ->where('customer_id', $customer->id)
            ->with(['album', 'customer', 'creator']);

        // Filter by approval status
        if ($request->boolean('approved')) {
            $query->approved();
        }

        // Filter by before/after group
        if ($request->has('before_after_group')) {
            $query->where('before_after_group', $request->before_after_group);
        }

        // For customers, only show their own photos
        if (auth()->user() && auth()->user()->id === $customer->id) {
            // Customer can see all their photos
        } else {
            // Staff can only see approved photos
            $query->approved();
        }

        $photos = $query->latest()->paginate(20);

        return response()->json($photos);
    }
}
