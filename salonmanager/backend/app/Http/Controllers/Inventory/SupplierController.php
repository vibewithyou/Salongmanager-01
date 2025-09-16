<?php

namespace App\Http\Controllers\Inventory;

use App\Http\Controllers\Controller;
use App\Models\Supplier;
use App\Policies\InventoryPolicy;
use Illuminate\Http\Request;

class SupplierController extends Controller 
{
    public function index()
    {
        $this->authorize('read', InventoryPolicy::class);
        
        return response()->json([
            'suppliers' => Supplier::where('salon_id', app('tenant')->id)
                ->orderBy('name')
                ->paginate(50)
        ]);
    }
    
    public function store(Request $request)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $validated = $request->validate([
            'name' => 'required|string|max:190',
            'email' => 'nullable|email',
            'phone' => 'nullable|string|max:50',
            'address' => 'nullable|array',
            'meta' => 'nullable|array'
        ]);
        
        $supplier = Supplier::create([
            'salon_id' => app('tenant')->id,
            ...$validated
        ]);
        
        return response()->json(['supplier' => $supplier], 201);
    }
    
    public function update(Request $request, Supplier $supplier)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $validated = $request->validate([
            'name' => 'required|string|max:190',
            'email' => 'nullable|email',
            'phone' => 'nullable|string|max:50',
            'address' => 'nullable|array',
            'meta' => 'nullable|array'
        ]);
        
        $supplier->update($validated);
        
        return response()->json(['supplier' => $supplier]);
    }
}