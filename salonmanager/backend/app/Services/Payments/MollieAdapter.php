<?php

namespace App\Services\Payments;

use App\Models\Invoice;
use Exception;
use Illuminate\Support\Facades\Log;
use Mollie\Api\MollieApiClient;

class MollieAdapter
{
    private MollieApiClient $mollie;

    public function __construct()
    {
        $this->mollie = new MollieApiClient();
        $this->mollie->setApiKey(config('payments.mollie.api_key'));
    }

    /**
     * Create a Mollie payment
     */
    public function createPayment(Invoice $invoice, string $description, string $returnUrl): array
    {
        try {
            $payment = $this->mollie->payments->create([
                'amount' => [
                    'currency' => config('payments.currency'),
                    'value' => number_format($invoice->total_gross, 2, '.', ''),
                ],
                'description' => $description,
                'redirectUrl' => $returnUrl . '?success=1&invoice=' . $invoice->id,
                'webhookUrl' => config('payments.mollie.webhook_url'),
                'metadata' => [
                    'invoice_id' => $invoice->id,
                    'salon_id' => $invoice->salon_id,
                ],
            ]);

            return [
                'id' => $payment->id,
                'url' => $payment->getCheckoutUrl(),
                'provider' => 'mollie',
            ];
        } catch (Exception $e) {
            Log::error('Mollie payment creation failed', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
            ]);
            throw $e;
        }
    }

    /**
     * Process a refund through Mollie
     */
    public function refund(Invoice $invoice, float $amount, ?string $reason = null): bool
    {
        try {
            $payment = $this->mollie->payments->get($invoice->payment_id);
            $refund = $payment->refund([
                'amount' => [
                    'currency' => config('payments.currency'),
                    'value' => number_format($amount, 2, '.', ''),
                ],
                'description' => $reason ?: "Refund for invoice {$invoice->number}",
            ]);

            Log::info('Mollie refund processed', [
                'invoice_id' => $invoice->id,
                'refund_id' => $refund->id,
                'amount' => $amount,
            ]);

            return true;
        } catch (Exception $e) {
            Log::error('Mollie refund failed', [
                'invoice_id' => $invoice->id,
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Handle Mollie webhook events
     */
    public function handleWebhook(string $payload, string $signature = null): bool
    {
        try {
            $data = json_decode($payload, true);
            $paymentId = $data['id'] ?? null;
            
            if (!$paymentId) {
                return false;
            }

            $payment = $this->mollie->payments->get($paymentId);
            $invoiceId = $payment->metadata->invoice_id ?? null;
            
            if (!$invoiceId) {
                return false;
            }

            $invoice = Invoice::find($invoiceId);
            if (!$invoice) {
                return false;
            }

            Log::info('Mollie webhook received', [
                'payment_id' => $paymentId,
                'status' => $payment->status,
                'invoice_id' => $invoiceId,
            ]);

            switch ($payment->status) {
                case 'paid':
                    $invoice->update([
                        'status' => 'paid',
                        'payment_id' => $paymentId,
                        'payment_provider' => 'mollie',
                    ]);
                    break;
                case 'failed':
                case 'expired':
                case 'canceled':
                    $invoice->update(['status' => 'failed']);
                    break;
                case 'refunded':
                    $invoice->update(['status' => 'refunded']);
                    break;
                default:
                    Log::info('Unhandled Mollie payment status', [
                        'status' => $payment->status,
                        'payment_id' => $paymentId,
                    ]);
                    break;
            }

            return true;
        } catch (Exception $e) {
            Log::error('Mollie webhook processing failed', [
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }

    /**
     * Get payment status from Mollie
     */
    public function getPaymentStatus(string $paymentId): ?string
    {
        try {
            $payment = $this->mollie->payments->get($paymentId);
            return $payment->status;
        } catch (Exception $e) {
            Log::error('Failed to get Mollie payment status', [
                'payment_id' => $paymentId,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }
}
