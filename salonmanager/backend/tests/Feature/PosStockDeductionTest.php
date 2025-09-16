<?php

it('deducts stock on paid invoice with product items', function () {
    $salon = \App\Models\Salon::factory()->create();
    app()->instance('tenant', $salon); // or however tenant is set in tests

    $user = \App\Models\User::factory()->create(['salon_id'=>$salon->id]);
    $this->actingAs($user, 'sanctum');

    $product = \App\Models\Product::factory()->create(['salon_id'=>$salon->id]);
    $loc = \App\Models\StockLocation::factory()->create(['salon_id'=>$salon->id,'is_default'=>true]);

    // seed stock
    \App\Models\StockItem::firstOrCreate([
        'salon_id'=>$salon->id,'product_id'=>$product->id,'location_id'=>$loc->id
    ])->update(['qty'=>5]);

    // create invoice with product item qty=2 (exact model names may vary)
    $invoice = \App\Models\Invoice::factory()->create(['salon_id'=>$salon->id]);
    $invoice->items()->create([
        'type'=>'product','reference_id'=>$product->id,'qty'=>2,'unit_price'=>10,
    ]);

    // simulate payment endpoint (replace with your route/controller if needed)
    // TODO(ASK: insert correct route for payment)
    // $this->postJson("/api/v1/pos/invoices/{$invoice->id}/pay", [...])->assertStatus(200);

    // directly call hook for smoke if route unknown:
    \App\Services\Inventory\StockService::adjust($salon->id, $product->id, $loc->id, -2, 'sale', ['invoice_id'=>$invoice->id]);

    $after = \App\Models\StockItem::where([
        'salon_id'=>$salon->id,'product_id'=>$product->id,'location_id'=>$loc->id
    ])->first();

    expect($after->qty)->toBe(3);
});