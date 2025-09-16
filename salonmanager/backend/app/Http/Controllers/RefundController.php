<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use App\Support\Idempotency\Idempotency;
use App\Models\Invoice;
use Stripe\StripeClient;
use Mollie\Api\MollieApiClient;

class RefundController extends Controller
{
    public function create(Request $request): JsonResponse
    {
        $request->validate([
            'invoice_id' => 'required|integer|exists:invoices,id',
            'amount' => 'required|numeric|min:0.01',
            'reason' => 'nullable|string|max:255',
        ]);

        $invoice = Invoice::findOrFail($request->invoice_id);
        
        // Check if invoice is eligible for refund
        if ($invoice->status !== 'paid') {
            return response()->json([
                'error' => 'Invoice must be paid to process refund',
                'status' => $invoice->status
            ], 400);
        }

        if ($request->amount > $invoice->total) {
            return response()->json([
                'error' => 'Refund amount cannot exceed invoice total',
                'max_amount' => $invoice->total
            ], 400);
        }

        // Generate idempotency key
        $idempotencyKey = $request->header('Idempotency-Key') ?? 
            Idempotency::generateKey('refund');

        return Idempotency::once($idempotencyKey, 'refund', function () use ($request, $invoice) {
            return $this->processRefund($request, $invoice);
        }, 60 * 24); // 24 hours TTL
    }

    private function processRefund(Request $request, Invoice $invoice): JsonResponse
    {
        try {
            DB::beginTransaction();

            // Log refund request
            $this->logRefundRequest($invoice, $request->amount, $request->reason);

            $refundResult = $this->processProviderRefund($invoice, $request->amount, $request->reason);

            // Update invoice status
            $invoice->update([
                'status' => 'refunded',
                'refunded_at' => now(),
                'refund_amount' => $request->amount,
                'refund_reason' => $request->reason,
            ]);

            // Log refund success
            $this->logRefundSuccess($invoice, $refundResult);

            DB::commit();

            return response()->json([
                'message' => 'Refund processed successfully',
                'refund_id' => $refundResult['refund_id'] ?? null,
                'amount' => $request->amount,
                'status' => 'success'
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            
            // Log refund failure
            $this->logRefundFailure($invoice, $e->getMessage());

            Log::error('Refund processing failed', [
                'invoice_id' => $invoice->id,
                'amount' => $request->amount,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'error' => 'Refund processing failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    private function processProviderRefund(Invoice $invoice, float $amount, ?string $reason): array
    {
        $provider = config('services.payment.provider', 'stripe');
        
        switch ($provider) {
            case 'stripe':
                return $this->processStripeRefund($invoice, $amount, $reason);
            case 'mollie':
                return $this->processMollieRefund($invoice, $amount, $reason);
            default:
                throw new \Exception("Unsupported payment provider: {$provider}");
        }
    }

    private function processStripeRefund(Invoice $invoice, float $amount, ?string $reason): array
    {
        $stripe = new StripeClient(config('services.stripe.secret'));
        
        $refund = $stripe->refunds->create([
            'payment_intent' => $invoice->payment_id,
            'amount' => (int) ($amount * 100), // Convert to cents
            'reason' => $reason ? 'requested_by_customer' : null,
            'metadata' => [
                'invoice_id' => $invoice->id,
                'reason' => $reason ?? 'No reason provided'
            ]
        ]);

        return [
            'refund_id' => $refund->id,
            'status' => $refund->status,
            'amount' => $refund->amount / 100, // Convert back from cents
        ];
    }

    private function processMollieRefund(Invoice $invoice, float $amount, ?string $reason): array
    {
        $mollie = new MollieApiClient();
        $mollie->setApiKey(config('services.mollie.key'));
        
        $payment = $mollie->payments->get($invoice->payment_id);
        
        $refund = $payment->refund([
            'amount' => [
                'currency' => 'EUR',
                'value' => number_format($amount, 2, '.', '')
            ],
            'description' => $reason ?? "Refund for invoice #{$invoice->id}"
        ]);

        return [
            'refund_id' => $refund->id,
            'status' => $refund->status,
            'amount' => $amount,
        ];
    }

    private function logRefundRequest(Invoice $invoice, float $amount, ?string $reason): void
    {
        Log::info('Refund requested', [
            'invoice_id' => $invoice->id,
            'amount' => $amount,
            'reason' => $reason,
            'payment_id' => $invoice->payment_id,
        ]);
    }

    private function logRefundSuccess(Invoice $invoice, array $refundResult): void
    {
        Log::info('Refund processed successfully', [
            'invoice_id' => $invoice->id,
            'refund_id' => $refundResult['refund_id'],
            'amount' => $refundResult['amount'],
            'status' => $refundResult['status'],
        ]);
    }

    private function logRefundFailure(Invoice $invoice, string $error): void
    {
        Log::error('Refund processing failed', [
            'invoice_id' => $invoice->id,
            'error' => $error,
        ]);
    }
}
