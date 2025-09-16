<?php

namespace App\Http\Controllers;

use App\Services\Payments\PaymentService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaymentWebhookController extends Controller
{
    private PaymentService $paymentService;

    public function __construct(PaymentService $paymentService)
    {
        $this->paymentService = $paymentService;
    }

    /**
     * Handle payment webhooks from Stripe or Mollie
     */
    public function handle(Request $request)
    {
        $payload = $request->getContent();
        $signature = $request->header('Stripe-Signature') ?? $request->header('X-Mollie-Signature');

        Log::info('Payment webhook received', [
            'provider' => config('payments.provider'),
            'has_signature' => !empty($signature),
            'payload_size' => strlen($payload),
        ]);

        try {
            $success = $this->paymentService->handleWebhook($payload, $signature);
            
            if ($success) {
                return response()->json(['status' => 'success'], 200);
            } else {
                return response()->json(['status' => 'error', 'message' => 'Webhook processing failed'], 400);
            }
        } catch (\Exception $e) {
            Log::error('Webhook processing error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return response()->json(['status' => 'error', 'message' => 'Internal server error'], 500);
        }
    }
}
