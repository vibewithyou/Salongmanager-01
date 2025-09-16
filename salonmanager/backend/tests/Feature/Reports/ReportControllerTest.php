<?php

namespace Tests\Feature\Reports;

use Tests\TestCase;
use App\Models\Salon;
use App\Models\User;
use App\Models\Invoice;
use App\Models\Booking;
use App\Models\Service;
use App\Models\Stylist;
use App\Models\BookingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Carbon\Carbon;

class ReportControllerTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Create test salon and user
        $this->salon = Salon::factory()->create();
        $this->user = User::factory()->create();
        $this->user->current_salon_id = $this->salon->id;
        $this->user->save();
        
        // Set tenant context
        app()->instance('tenant', $this->salon);
    }

    public function test_revenue_endpoint_returns_daily_revenue_data()
    {
        // Create test invoices
        Invoice::factory()->create([
            'salon_id' => $this->salon->id,
            'issued_at' => Carbon::now()->subDays(2),
            'total_gross' => 100.00,
        ]);
        
        Invoice::factory()->create([
            'salon_id' => $this->salon->id,
            'issued_at' => Carbon::now()->subDay(),
            'total_gross' => 150.00,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/reports/revenue?' . http_build_query([
                'from' => Carbon::now()->subDays(5)->toDateString(),
                'to' => Carbon::now()->toDateString(),
            ]));

        $response->assertStatus(200);
        $response->assertJsonStructure([
            '*' => [
                'day',
                'revenue',
            ]
        ]);
    }

    public function test_top_services_endpoint_returns_service_data()
    {
        // Create test service
        $service = Service::factory()->create([
            'salon_id' => $this->salon->id,
            'name' => 'Haircut',
        ]);

        // Create test booking and booking service
        $booking = Booking::factory()->create([
            'salon_id' => $this->salon->id,
            'start_at' => Carbon::now()->subDay(),
            'status' => 'confirmed',
        ]);

        BookingService::factory()->create([
            'booking_id' => $booking->id,
            'service_id' => $service->id,
            'price' => 50.00,
        ]);

        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/reports/top-services?' . http_build_query([
                'from' => Carbon::now()->subDays(5)->toDateString(),
                'to' => Carbon::now()->toDateString(),
            ]));

        $response->assertStatus(200);
        $response->assertJsonStructure([
            '*' => [
                'name',
                'cnt',
                'total_revenue',
            ]
        ]);
    }

    public function test_export_csv_returns_csv_data()
    {
        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/reports/export?' . http_build_query([
                'type' => 'revenue',
                'from' => Carbon::now()->subDays(5)->toDateString(),
                'to' => Carbon::now()->toDateString(),
            ]));

        $response->assertStatus(200);
        $response->assertHeader('Content-Type', 'text/csv');
    }

    public function test_reports_require_authentication()
    {
        $response = $this->getJson('/api/v1/reports/revenue');
        $response->assertStatus(401);
    }

    public function test_reports_require_tenant_context()
    {
        // Remove tenant context
        app()->forgetInstance('tenant');
        
        $response = $this->actingAs($this->user)
            ->getJson('/api/v1/reports/revenue');
        $response->assertStatus(500); // Should fail without tenant
    }
}