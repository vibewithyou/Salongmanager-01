<?php

namespace App\Http\Controllers\Inventory;

use App\Http\Controllers\Controller;
use App\Models\PurchaseOrder;
use App\Models\PurchaseOrderItem;
use App\Policies\InventoryPolicy;
use App\Services\Inventory\PoNumber;
use App\Services\Inventory\StockService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PurchaseOrderController extends Controller 
{
    public function index()
    {
        $this->authorize('read', InventoryPolicy::class);
        
        return response()->json([
            'pos' => PurchaseOrder::where('salon_id', app('tenant')->id)
                ->with('supplier:id,name')
                ->orderByDesc('id')
                ->paginate(20)
        ]);
    }
    
    public function store(Request $request)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $validated = $request->validate([
            'supplier_id' => ['required', 'exists:suppliers,id'],
            'items' => 'array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.qty' => 'required|integer|min:1',
            'items.*.unit_cost' => 'nullable|numeric|min:0',
            'meta' => 'nullable|array'
        ]);
        
        $po = DB::transaction(function() use ($validated) {
            $po = PurchaseOrder::create([
                'salon_id' => app('tenant')->id,
                'supplier_id' => $validated['supplier_id'],
                'number' => PoNumber::next(app('tenant')->id),
                'status' => 'draft',
                'meta' => $validated['meta'] ?? []
            ]);
            
            foreach ($validated['items'] as $item) {
                PurchaseOrderItem::create([
                    'po_id' => $po->id,
                    'product_id' => $item['product_id'],
                    'qty' => $item['qty'],
                    'unit_cost' => $item['unit_cost'] ?? 0
                ]);
            }
            
            return $po;
        });
        
        return response()->json(['po' => $po->load('items')], 201);
    }
    
    public function receive(Request $request, PurchaseOrder $po)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $validated = $request->validate([
            'location_id' => ['required', 'exists:stock_locations,id']
        ]);
        
        foreach ($po->items as $item) {
            StockService::adjust(
                $po->salon_id,
                $item->product_id,
                $validated['location_id'],
                +$item->qty,
                'po_receive',
                ['po_id' => $po->id]
            );
        }
        
        $po->update(['status' => 'received']);
        
        return response()->json(['po' => $po->fresh('items')]);
    }
}