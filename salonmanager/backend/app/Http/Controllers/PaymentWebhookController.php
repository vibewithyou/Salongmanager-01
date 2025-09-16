<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use App\Support\Idempotency\Idempotency;
use Stripe\Webhook;
use Stripe\Exception\SignatureVerificationException;
use Mollie\Api\MollieApiClient;

class PaymentWebhookController extends Controller
{
    public function handle(Request $request): JsonResponse
    {
        $provider = $request->route('provider');
        $rawPayload = $request->getContent();
        $signature = $request->header('Stripe-Signature') ?? $request->header('Mollie-Signature');
        
        // Generate idempotency key from payload
        $idempotencyKey = 'webhook_' . hash('sha256', $rawPayload . $signature);
        
        return Idempotency::once($idempotencyKey, 'webhook', function () use ($provider, $request, $rawPayload, $signature) {
            return $this->processWebhook($provider, $request, $rawPayload, $signature);
        }, 60 * 24); // 24 hours TTL for webhooks
    }
    
    private function processWebhook(string $provider, Request $request, string $rawPayload, ?string $signature): JsonResponse
    {
        try {
            switch ($provider) {
                case 'stripe':
                    return $this->handleStripeWebhook($rawPayload, $signature);
                case 'mollie':
                    return $this->handleMollieWebhook($rawPayload, $signature);
                default:
                    return response()->json(['error' => 'Unsupported provider'], 400);
            }
        } catch (\Exception $e) {
            Log::error('Webhook processing failed', [
                'provider' => $provider,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json(['error' => 'Webhook processing failed'], 500);
        }
    }
    
    private function handleStripeWebhook(string $rawPayload, ?string $signature): JsonResponse
    {
        $webhookSecret = config('services.stripe.webhook_secret');
        
        if (!$webhookSecret) {
            Log::warning('Stripe webhook secret not configured');
            return response()->json(['error' => 'Webhook secret not configured'], 500);
        }
        
        try {
            $event = Webhook::constructEvent($rawPayload, $signature, $webhookSecret);
        } catch (SignatureVerificationException $e) {
            Log::warning('Stripe webhook signature verification failed', ['error' => $e->getMessage()]);
            return response()->json(['error' => 'Invalid signature'], 400);
        }
        
        // Store webhook event
        $this->storeWebhookEvent('stripe', $event->type, $event->id, $event->toArray());
        
        // Process event
        $this->processStripeEvent($event);
        
        return response()->json(['status' => 'success']);
    }
    
    private function handleMollieWebhook(string $rawPayload, ?string $signature): JsonResponse
    {
        $mollie = new MollieApiClient();
        $mollie->setApiKey(config('services.mollie.key'));
        
        $data = json_decode($rawPayload, true);
        
        if (!$data || !isset($data['id'])) {
            return response()->json(['error' => 'Invalid payload'], 400);
        }
        
        // Store webhook event
        $this->storeWebhookEvent('mollie', 'payment.updated', $data['id'], $data);
        
        // Process event
        $this->processMollieEvent($data);
        
        return response()->json(['status' => 'success']);
    }
    
    private function storeWebhookEvent(string $provider, string $eventType, string $externalId, array $payload): void
    {
        DB::table('webhook_events')->insert([
            'provider' => $provider,
            'event_type' => $eventType,
            'external_id' => $externalId,
            'payload' => json_encode($payload),
            'processed_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
    
    private function processStripeEvent($event): void
    {
        switch ($event->type) {
            case 'payment_intent.succeeded':
                $this->handlePaymentSucceeded($event->data->object);
                break;
            case 'payment_intent.payment_failed':
                $this->handlePaymentFailed($event->data->object);
                break;
            case 'charge.dispute.created':
                $this->handleDisputeCreated($event->data->object);
                break;
            default:
                Log::info('Unhandled Stripe event type', ['type' => $event->type]);
        }
    }
    
    private function processMollieEvent(array $data): void
    {
        $status = $data['status'] ?? 'unknown';
        
        switch ($status) {
            case 'paid':
                $this->handlePaymentSucceeded($data);
                break;
            case 'failed':
            case 'canceled':
            case 'expired':
                $this->handlePaymentFailed($data);
                break;
            default:
                Log::info('Unhandled Mollie event status', ['status' => $status]);
        }
    }
    
    private function handlePaymentSucceeded($paymentData): void
    {
        Log::info('Payment succeeded', ['payment_data' => $paymentData]);
        
        // TODO: Update invoice status, send confirmation email, etc.
        // This would typically involve:
        // 1. Finding the invoice by payment ID
        // 2. Updating status to 'paid'
        // 3. Sending confirmation email
        // 4. Updating booking status if applicable
    }
    
    private function handlePaymentFailed($paymentData): void
    {
        Log::info('Payment failed', ['payment_data' => $paymentData]);
        
        // TODO: Update invoice status, send failure notification, etc.
    }
    
    private function handleDisputeCreated($disputeData): void
    {
        Log::warning('Payment dispute created', ['dispute_data' => $disputeData]);
        
        // TODO: Handle dispute, notify admin, etc.
    }
}