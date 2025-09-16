<?php

namespace App\Http\Controllers\Inventory;

use App\Http\Controllers\Controller;
use App\Http\Requests\Inventory\MovementRequest;
use App\Http\Requests\Inventory\TransferRequest;
use App\Models\StockItem;
use App\Models\StockMovement;
use App\Policies\InventoryPolicy;
use App\Services\Inventory\StockService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StockController extends Controller 
{
    public function overview(Request $request)
    {
        $this->authorize('read', InventoryPolicy::class);
        
        $salonId = app('tenant')->id;
        $items = StockItem::query()
            ->where('salon_id', $salonId)
            ->with(['product:id,name,sku,reorder_point,reorder_qty', 'location:id,name'])
            ->orderByDesc('updated_at')
            ->paginate($this->perPage($request, 50, 100));
            
        return response()->json(['items' => $items]);
    }

    public function lowStock(Request $request)
    {
        $this->authorize('read', InventoryPolicy::class);
        
        $salonId = app('tenant')->id;
        $rows = DB::table('stock_items')
            ->join('products', 'products.id', '=', 'stock_items.product_id')
            ->select('stock_items.*', 'products.name', 'products.sku', 'products.reorder_point')
            ->where('stock_items.salon_id', $salonId)
            ->whereColumn('stock_items.qty', '<', 'products.reorder_point')
            ->orderBy('products.name')
            ->get();
            
        return response()->json(['items' => $rows]);
    }

    public function inbound(MovementRequest $request)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $validated = $request->validated();
        $salonId = app('tenant')->id;
        
        $movement = StockService::adjust(
            $salonId,
            $validated['product_id'],
            $validated['location_id'],
            +$validated['qty'],
            'in',
            ['note' => $validated['note'] ?? null]
        );
        
        return response()->json(['movement' => $movement], 201);
    }

    public function outbound(MovementRequest $request)
    {
        $this->authorize('consume', InventoryPolicy::class);
        
        $validated = $request->validated();
        $salonId = app('tenant')->id;
        
        $movement = StockService::adjust(
            $salonId,
            $validated['product_id'],
            $validated['location_id'],
            -$validated['qty'],
            'out',
            ['note' => $validated['note'] ?? null]
        );
        
        return response()->json(['movement' => $movement], 201);
    }

    public function transfer(TransferRequest $request)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $validated = $request->validated();
        $salonId = app('tenant')->id;
        
        DB::transaction(function() use ($salonId, $validated) {
            StockService::adjust(
                $salonId,
                $validated['product_id'],
                $validated['from_location_id'],
                -$validated['qty'],
                'transfer',
                ['to' => $validated['to_location_id'], 'note' => $validated['note'] ?? null]
            );
            StockService::adjust(
                $salonId,
                $validated['product_id'],
                $validated['to_location_id'],
                +$validated['qty'],
                'transfer',
                ['from' => $validated['from_location_id'], 'note' => $validated['note'] ?? null]
            );
        });
        
        return response()->json(['ok' => true]);
    }

    public function movements(Request $request)
    {
        $this->authorize('read', InventoryPolicy::class);
        
        $query = StockMovement::query()->where('salon_id', app('tenant')->id);
        
        if ($productId = $request->query('product_id')) {
            $query->where('product_id', $productId);
        }
        
        return response()->json([
            'movements' => $query->orderByDesc('moved_at')->paginate(50)
        ]);
    }
}