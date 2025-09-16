<?php

namespace Tests\Unit\Services;

use App\Models\Invoice;
use App\Models\Salon;
use App\Services\Payments\PaymentService;
use App\Services\Payments\StripeAdapter;
use App\Services\Payments\MollieAdapter;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Mockery;
use Tests\TestCase;

class PaymentServiceTest extends TestCase
{
    use RefreshDatabase;

    private PaymentService $paymentService;
    private Invoice $invoice;
    private Salon $salon;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->salon = Salon::factory()->create();
        $this->invoice = Invoice::factory()->create([
            'salon_id' => $this->salon->id,
            'total_gross' => 100.00,
            'status' => 'open',
        ]);
        
        $this->paymentService = new PaymentService();
    }

    public function test_calculates_tax_correctly()
    {
        $amount = 100.00;
        $tax = $this->paymentService->calculateTax($amount);
        
        $this->assertEquals(19.00, $tax);
    }

    public function test_calculates_reduced_tax_correctly()
    {
        $amount = 100.00;
        $tax = $this->paymentService->calculateTax($amount, 'reduced');
        
        $this->assertEquals(7.00, $tax);
    }

    public function test_formats_amount_for_stripe()
    {
        config(['payments.provider' => 'stripe']);
        $service = new PaymentService();
        
        $amount = 100.50;
        $formatted = $service->formatAmount($amount);
        
        $this->assertEquals(10050, $formatted);
    }

    public function test_formats_amount_for_mollie()
    {
        config(['payments.provider' => 'mollie']);
        $service = new PaymentService();
        
        $amount = 100.50;
        $formatted = $service->formatAmount($amount);
        
        $this->assertEquals(10050, $formatted);
    }

    public function test_throws_exception_for_unknown_provider()
    {
        config(['payments.provider' => 'unknown']);
        $service = new PaymentService();
        
        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Unknown payment provider: unknown');
        
        $service->createPayment($this->invoice, 'https://example.com/return');
    }

    public function test_throws_exception_for_refund_without_payment_id()
    {
        $this->expectException(\Exception::class);
        $this->expectExceptionMessage('Invoice has no payment ID');
        
        $this->paymentService->refund($this->invoice, 50.00);
    }

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }
}
