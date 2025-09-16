<?php

namespace App\Http\Controllers;

use App\Models\Invoice;
use App\Services\Payments\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Log;

class PosController extends Controller
{
    private PaymentService $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    /**
     * Create a payment session for an invoice
     */
    public function charge(Request $request, Invoice $invoice)
    {
        abort_unless(Gate::allows('pos.use'), 403);
        
        $request->validate([
            'return_url' => 'required|url',
            'amount' => 'nullable|numeric|min:0.01',
        ]);

        $amount = $request->input('amount', $invoice->total_gross);
        $returnUrl = $request->input('return_url');

        // Validate amount doesn't exceed invoice total
        if ($amount > $invoice->total_gross) {
            return response()->json([
                'error' => 'Amount cannot exceed invoice total'
            ], 400);
        }

        try {
            $session = $this->paymentService->createPayment($invoice, $returnUrl);
            
            Log::info('Payment session created', [
                'invoice_id' => $invoice->id,
                'amount' => $amount,
                'provider' => config('payments.provider'),
            ]);

            return response()->json([
                'success' => true,
                'session' => $session,
                'invoice' => $invoice->fresh(),
            ]);
        } catch (\Exception $e) {
            Log::error('Payment session creation failed', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'error' => 'Failed to create payment session',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Process a refund for an invoice
     */
    public function refund(Request $request, Invoice $invoice)
    {
        abort_unless(Gate::allows('pos.manage'), 403);
        
        $request->validate([
            'amount' => 'required|numeric|min:0.01|max:' . $invoice->total_gross,
            'reason' => 'nullable|string|max:255',
        ]);

        $amount = (float) $request->input('amount');
        $reason = $request->input('reason');

        if (!$invoice->payment_id) {
            return response()->json([
                'error' => 'Invoice has no payment to refund'
            ], 400);
        }

        try {
            $success = $this->paymentService->refund($invoice, $amount, $reason);
            
            if ($success) {
                Log::info('Refund processed', [
                    'invoice_id' => $invoice->id,
                    'amount' => $amount,
                    'reason' => $reason,
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Refund processed successfully',
                    'invoice' => $invoice->fresh(),
                ]);
            } else {
                return response()->json([
                    'error' => 'Refund processing failed'
                ], 500);
            }
        } catch (\Exception $e) {
            Log::error('Refund processing failed', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'error' => 'Refund processing failed',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get payment status for an invoice
     */
    public function status(Invoice $invoice)
    {
        abort_unless(Gate::allows('pos.use'), 403);

        if (!$invoice->payment_id) {
            return response()->json([
                'status' => 'no_payment',
                'message' => 'No payment associated with this invoice',
            ]);
        }

        try {
            $status = $this->paymentService->getPaymentStatus($invoice->payment_id);
            
            return response()->json([
                'status' => $status,
                'invoice_status' => $invoice->status,
                'payment_id' => $invoice->payment_id,
                'provider' => $invoice->payment_provider,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to get payment status', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'error' => 'Failed to get payment status',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get open invoices for POS
     */
    public function openInvoices(Request $request)
    {
        abort_unless(Gate::allows('pos.use'), 403);

        $query = Invoice::where('salon_id', app('tenant')->id)
            ->whereIn('status', ['open', 'pending'])
            ->with(['customer', 'items'])
            ->orderBy('created_at', 'desc');

        // Filter by customer if provided
        if ($request->has('customer_id')) {
            $query->where('customer_id', $request->input('customer_id'));
        }

        // Filter by date range if provided
        if ($request->has('from')) {
            $query->whereDate('created_at', '>=', $request->input('from'));
        }
        if ($request->has('to')) {
            $query->whereDate('created_at', '<=', $request->input('to'));
        }

        $invoices = $query->paginate($request->input('per_page', 15));

        return response()->json([
            'invoices' => $invoices,
        ]);
    }
}
