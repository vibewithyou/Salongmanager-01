<?php

namespace App\Http\Controllers\Pos;

use App\Http\Controllers\Controller;
use App\Http\Requests\Pos\PaymentRequest;
use App\Models\Payment;
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
        }
        
        // TODO: external provider capture stub
        
        return response()->json([
            'payment' => $payment,
            'invoice' => $invoice->fresh('payments')
        ]);
    }
}