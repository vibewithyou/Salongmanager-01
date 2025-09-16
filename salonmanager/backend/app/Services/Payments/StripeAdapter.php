<?php

namespace App\Services\Payments;

use App\Models\Invoice;
use Exception;
use Illuminate\Support\Facades\Log;
use Stripe\StripeClient;
use Stripe\Webhook;

class StripeAdapter
{
    private StripeClient $stripe;

    public function __construct()
    {
        $this->stripe = new StripeClient(config('payments.stripe.secret_key'));
    }

    /**
     * Create a Stripe payment session
     */
    public function createPayment(Invoice $invoice, string $description, string $returnUrl): array
    {
        try {
            $session = $this->stripe->checkout->sessions->create([
                'payment_method_types' => ['card'],
                'line_items' => [[
                    'price_data' => [
                        'currency' => strtolower(config('payments.currency')),
                        'product_data' => [
                            'name' => $description,
                        ],
                        'unit_amount' => $this->formatAmount($invoice->total_gross),
                    ],
                    'quantity' => 1,
                ]],
                'mode' => 'payment',
                'success_url' => $returnUrl . '?success=1&invoice=' . $invoice->id,
                'cancel_url' => $returnUrl . '?canceled=1&invoice=' . $invoice->id,
                'metadata' => [
                    'invoice_id' => $invoice->id,
                    'salon_id' => $invoice->salon_id,
                ],
            ]);

            return [
                'id' => $session->id,
                'url' => $session->url,
                'provider' => 'stripe',
            ];
        } catch (Exception $e) {
            Log::error('Stripe payment creation failed', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
            ]);
            throw $e;
        }
    }

    /**
     * Process a refund through Stripe
     */
    public function refund(Invoice $invoice, float $amount, ?string $reason = null): bool
    {
        try {
            $refund = $this->stripe->refunds->create([
                'payment_intent' => $invoice->payment_id,
                'amount' => $this->formatAmount($amount),
                'reason' => $reason ? 'requested_by_customer' : null,
                'metadata' => [
                    'invoice_id' => $invoice->id,
                    'salon_id' => $invoice->salon_id,
                ],
            ]);

            Log::info('Stripe refund processed', [
                'invoice_id' => $invoice->id,
                'refund_id' => $refund->id,
                'amount' => $amount,
            ]);

            return true;
        } catch (Exception $e) {
            Log::error('Stripe refund failed', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Handle Stripe webhook events
     */
    public function handleWebhook(string $payload, string $signature): bool
    {
        try {
            $event = Webhook::constructEvent(
                $payload,
                $signature,
                config('payments.stripe.webhook_secret')
            );

            Log::info('Stripe webhook received', [
                'type' => $event->type,
                'id' => $event->id,
            ]);

            switch ($event->type) {
                case 'checkout.session.completed':
                    return $this->handleCheckoutCompleted($event->data->object);
                case 'payment_intent.succeeded':
                    return $this->handlePaymentSucceeded($event->data->object);
                case 'payment_intent.payment_failed':
                    return $this->handlePaymentFailed($event->data->object);
                default:
                    Log::info('Unhandled Stripe webhook event', ['type' => $event->type]);
                    return true;
            }
        } catch (Exception $e) {
            Log::error('Stripe webhook processing failed', [
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Get payment status from Stripe
     */
    public function getPaymentStatus(string $paymentId): ?string
    {
        try {
            $paymentIntent = $this->stripe->paymentIntents->retrieve($paymentId);
            return $paymentIntent->status;
        } catch (Exception $e) {
            Log::error('Failed to get Stripe payment status', [
                'payment_id' => $paymentId,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Handle checkout session completed
     */
    private function handleCheckoutCompleted($session): bool
    {
        $invoiceId = $session->metadata->invoice_id ?? null;
        if (!$invoiceId) {
            return false;
        }

        $invoice = Invoice::find($invoiceId);
        if (!$invoice) {
            return false;
        }

        $invoice->update([
            'status' => 'paid',
            'payment_id' => $session->payment_intent,
            'payment_provider' => 'stripe',
        ]);

        Log::info('Invoice marked as paid via Stripe webhook', [
            'invoice_id' => $invoiceId,
            'session_id' => $session->id,
        ]);

        return true;
    }

    /**
     * Handle payment intent succeeded
     */
    private function handlePaymentSucceeded($paymentIntent): bool
    {
        // This is handled by checkout.session.completed for most cases
        return true;
    }

    /**
     * Handle payment intent failed
     */
    private function handlePaymentFailed($paymentIntent): bool
    {
        // Could update invoice status to 'failed' if needed
        Log::warning('Stripe payment failed', [
            'payment_intent_id' => $paymentIntent->id,
        ]);
        return true;
    }

    /**
     * Format amount for Stripe (convert to cents)
     */
    private function formatAmount(float $amount): int
    {
        return (int) round($amount * 100);
    }
}
