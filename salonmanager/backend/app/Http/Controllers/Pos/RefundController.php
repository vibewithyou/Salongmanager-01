<?php

namespace App\Http\Controllers\Pos;

use App\Http\Controllers\Controller;
use App\Http\Requests\Pos\RefundRequest;
use App\Models\Refund;
use Illuminate\Support\Facades\Gate;

class RefundController extends Controller
{
    public function refund(RefundRequest $request, Invoice $invoice)
    {
        abort_unless(Gate::allows('pos.manage'), 403);
        
        $data = $request->validated();
        
        $refund = Refund::create([
            'salon_id' => app('tenant')->id,
            'invoice_id' => $invoice->id,
            'amount' => $data['amount'],
            'reason' => $data['reason'] ?? null,
            'lines' => $data['lines'] ?? null,
            'refunded_at' => now(),
        ]);
        
        // Mark invoice refunded if total refunds >= total_gross
        $sum = Refund::where('invoice_id', $invoice->id)->sum('amount');
        if ($sum >= $invoice->total_gross) {
            $invoice->update(['status' => 'refunded']);
        }
        
        // TODO: external provider reversal stub
        
        return response()->json([
            'refund' => $refund,
            'invoice' => $invoice->fresh()
        ]);
    }
}