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
        $provider = config('payments.provider');
        $payload = $request->getContent();
        $signature = $request->header('Stripe-Signature') ?? $request->header('X-Mollie-Signature');

        Log::info('Payment webhook received', [
            'provider' => $provider,
            'has_signature' => !empty($signature),
            'payload_size' => strlen($payload),
        ]);

        // Verify webhook signature
        if ($provider === 'stripe') {
            $secret = env('STRIPE_WEBHOOK_SECRET');
            if (!$secret) {
                Log::error('Stripe webhook secret not configured');
                return response()->json(['error' => 'Webhook secret not configured'], 500);
            }
            
            try {
                $event = \Stripe\Webhook::constructEvent($payload, $signature, $secret);
            } catch (\Throwable $e) {
                Log::error('Stripe webhook signature verification failed', ['error' => $e->getMessage()]);
                return response()->json(['error' => 'Invalid signature'], 400);
            }
        } elseif ($provider === 'mollie') {
            // For Mollie, verify the payment ID exists and is valid
            $data = json_decode($payload, true);
            $paymentId = $data['id'] ?? null;
            if (!$paymentId) {
                return response()->json(['error' => 'Invalid payload'], 400);
            }
            // Additional verification could be done by fetching the payment from Mollie API
        }

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
