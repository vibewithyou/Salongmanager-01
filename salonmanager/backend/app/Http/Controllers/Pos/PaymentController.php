<?php

namespace App\Http\Controllers\Pos;

use App\Http\Controllers\Controller;
use App\Http\Requests\Pos\PaymentRequest;
use App\Models\Payment;
use App\Models\Invoice;
use App\Models\StockLocation;
use App\Services\Inventory\StockService;
use Illuminate\Support\Facades\Gate;

class PaymentController extends Controller
{
    public function pay(PaymentRequest $request, Invoice $invoice)
    {
        abort_unless(Gate::allows('pos.use'), 403);
        
        $data = $request->validated();
        
        $payment = Payment::create([
            'salon_id' => app('tenant')->id,
            'invoice_id' => $invoice->id,
            'method' => $data['method'],
            'amount' => $data['amount'],
            'meta' => $data['meta'] ?? [],
            'paid_at' => now(),
        ]);
        
        $paid = $invoice->payments()->sum('amount');
        if ($paid >= $invoice->total_gross) {
            $invoice->update(['status' => 'paid']);
            
            // Reduce stock for product items when payment is complete
            $invoice->load('items');
            $defaultLocation = StockLocation::where('salon_id', app('tenant')->id)
                ->where('is_default', true)
                ->first();
            $locationId = $defaultLocation?->id ?? StockLocation::where('salon_id', app('tenant')->id)->value('id');
            
            foreach ($invoice->items as $item) {
                if ($item->type === 'product' && $locationId && $item->reference_id) {
                    // Reduce stock for product sales
                    StockService::adjust(
                        app('tenant')->id,
                        (int)$item->reference_id,
                        $locationId,
                        -$item->qty,
                        'sale',
                        ['invoice_id' => $invoice->id]
                    );
                }
            }
        }
        
        // TODO: external provider capture stub
        
        return response()->json([
            'payment' => $payment,
            'invoice' => $invoice->fresh('payments')
        ]);
    }
}