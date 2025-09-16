<?php

namespace App\Services\Payments;

use App\Models\Invoice;
use Exception;
use Illuminate\Support\Facades\Log;

class PaymentService
{
    private string $provider;
    private ?StripeAdapter $stripe = null;
    private ?MollieAdapter $mollie = null;

    public function __construct()
    {
        $this->provider = config('payments.provider');
        
        if ($this->provider === 'stripe') {
            $this->stripe = new StripeAdapter();
        } elseif ($this->provider === 'mollie') {
            $this->mollie = new MollieAdapter();
        }
    }

    /**
     * Create a payment session for an invoice
     */
    public function createPayment(Invoice $invoice, string $returnUrl): array
    {
        $description = "Invoice {$invoice->number} - {$invoice->salon->name}";
        
        if ($this->provider === 'stripe') {
            return $this->stripe->createPayment($invoice, $description, $returnUrl);
        } elseif ($this->provider === 'mollie') {
            return $this->mollie->createPayment($invoice, $description, $returnUrl);
        }
        
        throw new Exception("Unknown payment provider: {$this->provider}");
    }

    /**
     * Process a refund for an invoice
     */
    public function refund(Invoice $invoice, float $amount, ?string $reason = null): bool
    {
        if (!$invoice->payment_id) {
            throw new Exception("Invoice has no payment ID");
        }

        if ($this->provider === 'stripe') {
            return $this->stripe->refund($invoice, $amount, $reason);
        } elseif ($this->provider === 'mollie') {
            return $this->mollie->refund($invoice, $amount, $reason);
        }
        
        throw new Exception("Unknown payment provider: {$this->provider}");
    }

    /**
     * Verify webhook signature and process payment event
     */
    public function handleWebhook(string $payload, string $signature): bool
    {
        if ($this->provider === 'stripe') {
            return $this->stripe->handleWebhook($payload, $signature);
        } elseif ($this->provider === 'mollie') {
            return $this->mollie->handleWebhook($payload, $signature);
        }
        
        throw new Exception("Unknown payment provider: {$this->provider}");
    }

    /**
     * Get payment status from provider
     */
    public function getPaymentStatus(string $paymentId): ?string
    {
        if ($this->provider === 'stripe') {
            return $this->stripe->getPaymentStatus($paymentId);
        } elseif ($this->provider === 'mollie') {
            return $this->mollie->getPaymentStatus($paymentId);
        }
        
        return null;
    }

    /**
     * Calculate tax amount based on rate
     */
    public function calculateTax(float $amount, string $rate = 'default'): float
    {
        $taxRate = config("payments.tax_rates.{$rate}", config('payments.tax_rates.default'));
        return round($amount * $taxRate, 2);
    }

    /**
     * Format amount for provider (convert to cents for Stripe)
     */
    public function formatAmount(float $amount): int
    {
        if ($this->provider === 'stripe') {
            return (int) round($amount * 100);
        }
        
        return (int) round($amount * 100); // Mollie also uses cents
    }
}
