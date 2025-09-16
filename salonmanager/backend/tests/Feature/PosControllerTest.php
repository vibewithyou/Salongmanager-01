<?php

namespace Tests\Feature;

use App\Models\Invoice;
use App\Models\Salon;
use App\Models\User;
use App\Services\Payments\PaymentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Mockery;
use Tests\TestCase;

class PosControllerTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Salon $salon;
    private Invoice $invoice;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->salon = Salon::factory()->create();
        $this->user = User::factory()->create([
            'current_salon_id' => $this->salon->id,
        ]);
        $this->invoice = Invoice::factory()->create([
            'salon_id' => $this->salon->id,
            'total_gross' => 100.00,
            'status' => 'open',
        ]);
    }

    public function test_charge_invoice_requires_authentication()
    {
        $response = $this->postJson("/api/v1/pos/invoices/{$this->invoice->id}/charge", [
            'return_url' => 'https://example.com/return',
        ]);

        $response->assertStatus(401);
    }

    public function test_charge_invoice_requires_pos_permission()
    {
        $this->actingAs($this->user);
        
        $response = $this->postJson("/api/v1/pos/invoices/{$this->invoice->id}/charge", [
            'return_url' => 'https://example.com/return',
        ]);

        $response->assertStatus(403);
    }

    public function test_charge_invoice_creates_payment_session()
    {
        $this->actingAs($this->user);
        
        // Mock the PaymentService
        $mockPaymentService = Mockery::mock(PaymentService::class);
        $mockPaymentService->shouldReceive('createPayment')
            ->once()
            ->andReturn([
                'id' => 'test_session_id',
                'url' => 'https://stripe.com/checkout/test',
                'provider' => 'stripe',
            ]);
        
        $this->app->instance(PaymentService::class, $mockPaymentService);
        
        $response = $this->postJson("/api/v1/pos/invoices/{$this->invoice->id}/charge", [
            'return_url' => 'https://example.com/return',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'session' => ['id', 'url', 'provider'],
                'invoice',
            ]);
    }

    public function test_charge_invoice_validates_amount()
    {
        $this->actingAs($this->user);
        
        $response = $this->postJson("/api/v1/pos/invoices/{$this->invoice->id}/charge", [
            'return_url' => 'https://example.com/return',
            'amount' => 150.00, // Exceeds invoice total
        ]);

        $response->assertStatus(400)
            ->assertJsonValidationErrors(['amount']);
    }

    public function test_refund_invoice_requires_authentication()
    {
        $response = $this->postJson("/api/v1/pos/invoices/{$this->invoice->id}/refund-payment", [
            'amount' => 50.00,
        ]);

        $response->assertStatus(401);
    }

    public function test_refund_invoice_requires_manage_permission()
    {
        $this->actingAs($this->user);
        
        $response = $this->postJson("/api/v1/pos/invoices/{$this->invoice->id}/refund-payment", [
            'amount' => 50.00,
        ]);

        $response->assertStatus(403);
    }

    public function test_refund_invoice_validates_amount()
    {
        $this->actingAs($this->user);
        
        $response = $this->postJson("/api/v1/pos/invoices/{$this->invoice->id}/refund-payment", [
            'amount' => 150.00, // Exceeds invoice total
        ]);

        $response->assertStatus(400)
            ->assertJsonValidationErrors(['amount']);
    }

    public function test_get_payment_status_requires_authentication()
    {
        $response = $this->getJson("/api/v1/pos/invoices/{$this->invoice->id}/payment-status");

        $response->assertStatus(401);
    }

    public function test_get_open_invoices_requires_authentication()
    {
        $response = $this->getJson('/api/v1/pos/invoices/open');

        $response->assertStatus(401);
    }

    public function test_get_open_invoices_returns_paginated_results()
    {
        $this->actingAs($this->user);
        
        // Create additional invoices
        Invoice::factory()->count(5)->create([
            'salon_id' => $this->salon->id,
            'status' => 'open',
        ]);
        
        $response = $this->getJson('/api/v1/pos/invoices/open');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'invoices' => [
                    'data',
                    'current_page',
                    'per_page',
                    'total',
                ],
            ]);
    }

    protected function tearDown(): void
    {
        Mockery::close();
        parent::tearDown();
    }
}
