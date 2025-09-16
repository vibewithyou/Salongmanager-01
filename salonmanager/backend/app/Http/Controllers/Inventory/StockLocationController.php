<?php

namespace App\Http\Controllers\Inventory;

use App\Http\Controllers\Controller;
use App\Models\StockLocation;
use App\Policies\InventoryPolicy;
use Illuminate\Http\Request;

class StockLocationController extends Controller 
{
    public function index()
    {
        $this->authorize('read', InventoryPolicy::class);
        
        return response()->json([
            'locations' => StockLocation::where('salon_id', app('tenant')->id)
                ->orderBy('name')
                ->get()
        ]);
    }
    
    public function store(Request $request)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $validated = $request->validate([
            'name' => 'required|string|max:120',
            'is_default' => 'boolean',
            'meta' => 'nullable|array'
        ]);
        
        $location = StockLocation::create([
            'salon_id' => app('tenant')->id,
            ...$validated
        ]);
        
        return response()->json(['location' => $location], 201);
    }
    
    public function update(Request $request, StockLocation $location)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $validated = $request->validate([
            'name' => 'required|string|max:120',
            'is_default' => 'boolean',
            'meta' => 'nullable|array'
        ]);
        
        $location->update($validated);
        
        return response()->json(['location' => $location]);
    }
}