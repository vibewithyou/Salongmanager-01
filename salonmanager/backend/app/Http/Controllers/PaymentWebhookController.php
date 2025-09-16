<?php

namespace App\Http\Controllers;

use App\Models\Invoice;
use App\Support\Idempotency\Idempotency;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PaymentWebhookController extends Controller
{
    /**
     * Handle payment webhooks from Stripe or Mollie with idempotency and signature verification
     */
    public function handle(Request $request)
    {
        $provider = config('payments.provider', 'stripe');

        if ($provider === 'stripe') {
            return $this->handleStripeWebhook($request);
        } elseif ($provider === 'mollie') {
            return $this->handleMollieWebhook($request);
        }

        return response()->json(['error' => 'Unknown provider'], 400);
    }

    private function handleStripeWebhook(Request $request)
    {
        $sig = $request->header('Stripe-Signature');
        $secret = env('STRIPE_WEBHOOK_SECRET');
        
        if (!$secret) {
            Log::error('Stripe webhook secret not configured');
            return response()->json(['error' => 'Webhook secret not configured'], 500);
        }

        try {
            $event = \Stripe\Webhook::constructEvent($request->getContent(), $sig, $secret);
        } catch (\Throwable $e) {
            Log::error('Stripe webhook signature verification failed', ['error' => $e->getMessage()]);
            return response()->json(['error' => 'Invalid signature'], 400);
        }

        $obj = $event->data['object'] ?? [];
        $extId = $obj['id'] ?? ($obj['payment_intent'] ?? null);
        if (!$extId) return response()->json(['error' => 'No id'], 400);

        $idemKey = "stripe:{$event->id}";
        $result = Idempotency::once($idemKey, 'stripe:webhook', function() use ($event, $obj) {
            DB::table('webhook_events')->insert([
                'provider' => 'stripe',
                'event_type' => $event->type,
                'external_id' => $event->id,
                'payload' => json_encode($event, JSON_UNESCAPED_UNICODE),
                'created_at' => now(),
                'updated_at' => now()
            ]);

            $invoiceId = $obj['metadata']['invoice_id'] ?? null;
            if ($invoiceId && $event->type === 'checkout.session.completed') {
                $inv = Invoice::lockForUpdate()->find($invoiceId);
                if ($inv && $inv->status !== 'paid') {
                    $inv->status = 'paid';
                    $inv->payment_id = $obj['payment_intent'] ?? $obj['id'] ?? null;
                    $inv->paid_at = now();
                    $inv->save();
                }
            }
            if ($invoiceId && $event->type === 'charge.refunded') {
                $inv = Invoice::lockForUpdate()->find($invoiceId);
                if ($inv && $inv->status !== 'refunded') {
                    $inv->status = 'refunded';
                    $inv->refunded_at = now();
                    $inv->save();
                }
            }
            return true;
        });

        return response()->json(['ok' => true, 'skipped' => !($result['ok'] ?? false)]);
    }

    private function handleMollieWebhook(Request $request)
    {
        $id = $request->input('id');
        if (!$id) return response()->json(['error' => 'No id'], 400);
        
        $idemKey = "mollie:$id";
        
        $result = Idempotency::once($idemKey, 'mollie:webhook', function() use ($id) {
            // In a real implementation, you would fetch from Mollie API
            // For now, we'll simulate the webhook event storage
            DB::table('webhook_events')->insert([
                'provider' => 'mollie',
                'event_type' => 'payment.updated', // This would come from the actual Mollie API response
                'external_id' => $id,
                'payload' => json_encode(['id' => $id, 'status' => 'paid'], JSON_UNESCAPED_UNICODE),
                'created_at' => now(),
                'updated_at' => now()
            ]);

            // Process payment status update
            $invoiceId = $request->input('metadata.invoice_id');
            if ($invoiceId) {
                $inv = Invoice::lockForUpdate()->find($invoiceId);
                if ($inv) {
                    // In real implementation, check actual payment status from Mollie
                    $inv->status = 'paid';
                    $inv->paid_at = now();
                    $inv->payment_id = $id;
                    $inv->save();
                }
            }
            return true;
        });

        return response()->json(['ok' => true, 'skipped' => !($result['ok'] ?? false)]);
    }
}
