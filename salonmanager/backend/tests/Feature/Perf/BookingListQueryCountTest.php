<?php

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\User;
use App\Models\Salon;
use App\Models\Booking;
use App\Models\Customer;
use App\Models\Stylist;
use App\Models\Service;
use Illuminate\Support\Facades\DB;

class BookingListQueryCountTest extends TestCase
{
    use RefreshDatabase;

    public function test_booking_index_runs_within_reasonable_queries(): void
    {
        // Create test data
        $salon = Salon::factory()->create();
        $customer = Customer::factory()->create(['salon_id' => $salon->id]);
        $stylist = Stylist::factory()->create(['salon_id' => $salon->id]);
        $service = Service::factory()->create(['salon_id' => $salon->id]);

        // Create multiple bookings with relationships
        Booking::factory()->count(10)->create([
            'salon_id' => $salon->id,
            'customer_id' => $customer->id,
            'stylist_id' => $stylist->id,
            'service_id' => $service->id,
        ]);

        // Set tenant context
        app()->instance('tenant', $salon);

        // Enable query log
        DB::enableQueryLog();

        // Make request
        $response = $this->getJson('/api/v1/bookings?per_page=10');

        // Get query count
        $queryCount = count(DB::getQueryLog());

        // Assertions
        $response->assertOk();
        $this->assertLessThanOrEqual(25, $queryCount, 
            "Booking index used {$queryCount} queries, expected ≤ 25. " .
            "This indicates potential N+1 query issues."
        );

        // Log the actual queries for debugging
        if ($queryCount > 25) {
            $queries = collect(DB::getQueryLog())->map(fn($q) => $q['query']);
            dump("Queries executed: {$queryCount}");
            dump($queries->toArray());
        }
    }

    public function test_review_index_runs_within_reasonable_queries(): void
    {
        // Create test data
        $salon = Salon::factory()->create();
        $user = User::factory()->create();

        // Create multiple reviews
        \App\Models\Review::factory()->count(15)->create([
            'salon_id' => $salon->id,
            'user_id' => $user->id,
            'approved' => true,
        ]);

        // Set tenant context
        app()->instance('tenant', $salon);

        // Enable query log
        DB::enableQueryLog();

        // Make request
        $response = $this->getJson('/api/v1/reviews?per_page=15');

        // Get query count
        $queryCount = count(DB::getQueryLog());

        // Assertions
        $response->assertOk();
        $this->assertLessThanOrEqual(20, $queryCount, 
            "Review index used {$queryCount} queries, expected ≤ 20. " .
            "This indicates potential N+1 query issues."
        );
    }

    public function test_invoice_list_runs_within_reasonable_queries(): void
    {
        // Create test data
        $salon = Salon::factory()->create();
        $customer = Customer::factory()->create(['salon_id' => $salon->id]);

        // Create multiple invoices with items
        for ($i = 0; $i < 10; $i++) {
            $invoice = \App\Models\Invoice::factory()->create([
                'salon_id' => $salon->id,
                'customer_id' => $customer->id,
            ]);

            // Add invoice items
            \App\Models\InvoiceItem::factory()->count(3)->create([
                'invoice_id' => $invoice->id,
            ]);
        }

        // Set tenant context
        app()->instance('tenant', $salon);

        // Enable query log
        DB::enableQueryLog();

        // Make request
        $response = $this->getJson('/api/v1/pos/invoices/open?per_page=10');

        // Get query count
        $queryCount = count(DB::getQueryLog());

        // Assertions
        $response->assertOk();
        $this->assertLessThanOrEqual(15, $queryCount, 
            "Invoice list used {$queryCount} queries, expected ≤ 15. " .
            "This indicates potential N+1 query issues."
        );
    }

    public function test_stock_overview_runs_within_reasonable_queries(): void
    {
        // Create test data
        $salon = Salon::factory()->create();
        $product = \App\Models\Product::factory()->create(['salon_id' => $salon->id]);
        $location = \App\Models\StockLocation::factory()->create(['salon_id' => $salon->id]);

        // Create multiple stock items
        \App\Models\StockItem::factory()->count(20)->create([
            'salon_id' => $salon->id,
            'product_id' => $product->id,
            'location_id' => $location->id,
        ]);

        // Set tenant context
        app()->instance('tenant', $salon);

        // Enable query log
        DB::enableQueryLog();

        // Make request
        $response = $this->getJson('/api/v1/inventory/stock?per_page=20');

        // Get query count
        $queryCount = count(DB::getQueryLog());

        // Assertions
        $response->assertOk();
        $this->assertLessThanOrEqual(10, $queryCount, 
            "Stock overview used {$queryCount} queries, expected ≤ 10. " .
            "This indicates potential N+1 query issues."
        );
    }
}
