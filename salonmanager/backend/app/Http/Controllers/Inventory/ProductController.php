<?php

namespace App\Http\Controllers\Inventory;

use App\Http\Controllers\Controller;
use App\Http\Requests\Inventory\ProductUpsertRequest;
use App\Models\Product;
use App\Models\ProductPrice;
use App\Policies\InventoryPolicy;
use Illuminate\Http\Request;

class ProductController extends Controller 
{
    public function index(Request $request)
    {
        $this->authorize('read', InventoryPolicy::class);
        
        $query = Product::query()->where('salon_id', app('tenant')->id);
        
        if ($search = $request->query('search')) {
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%$search%")
                  ->orWhere('sku', 'like', "%$search%");
            });
        }
        
        return response()->json([
            'products' => $query->with('price')->orderBy('name')->paginate(20)
        ]);
    }

    public function store(ProductUpsertRequest $request)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $product = Product::create(array_merge(
            $request->validated(),
            ['salon_id' => app('tenant')->id]
        ));
        
        if ($price = $request->validated()['price'] ?? null) {
            ProductPrice::where('product_id', $product->id)->update(['active' => false]);
            ProductPrice::create([
                'product_id' => $product->id,
                'net_price' => $price['net_price'],
                'tax_rate' => $price['tax_rate'],
                'gross_price' => $price['gross_price'],
                'active' => true
            ]);
        }
        
        return response()->json(['product' => $product->load('price')], 201);
    }

    public function update(ProductUpsertRequest $request, Product $product)
    {
        $this->authorize('write', InventoryPolicy::class);
        
        $product->fill($request->validated())->save();
        
        if ($price = $request->validated()['price'] ?? null) {
            ProductPrice::where('product_id', $product->id)->update(['active' => false]);
            ProductPrice::create([
                'product_id' => $product->id,
                'net_price' => $price['net_price'],
                'tax_rate' => $price['tax_rate'],
                'gross_price' => $price['gross_price'],
                'active' => true
            ]);
        }
        
        return response()->json(['product' => $product->fresh('price')]);
    }
}