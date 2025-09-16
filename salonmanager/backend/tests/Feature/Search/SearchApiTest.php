<?php

use App\Models\Salon;
use App\Models\Service;
use App\Models\OpeningHour;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->salon = Salon::factory()->create([
        'name' => 'Test Salon',
        'city' => 'Berlin',
        'rating_avg' => 4.5,
        'location' => DB::raw("ST_SRID(POINT(13.4050, 52.5200), 4326)"),
    ]);
    
    $this->service = Service::factory()->create([
        'salon_id' => $this->salon->id,
        'name' => 'Haircut',
        'price' => 50.00,
    ]);
    
    // Create opening hours for Monday (1) 9:00-18:00
    OpeningHour::factory()->create([
        'salon_id' => $this->salon->id,
        'weekday' => 1,
        'open_time' => '09:00:00',
        'close_time' => '18:00:00',
        'closed' => false,
    ]);
});

test('search returns salons by name', function () {
    $response = $this->getJson('/api/v1/search/salons?q=Test');
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'items')
        ->assertJsonPath('items.0.name', 'Test Salon');
});

test('search filters by location and radius', function () {
    $response = $this->getJson('/api/v1/search/salons?lat=52.5200&lng=13.4050&radius_km=5');
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'items')
        ->assertJsonStructure([
            'items' => [
                '*' => [
                    'distance_km',
                ],
            ],
        ]);
});

test('search filters by service', function () {
    $response = $this->getJson("/api/v1/search/salons?service_id={$this->service->id}");
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'items');
});

test('search filters by price range', function () {
    $response = $this->getJson('/api/v1/search/salons?price_min=40&price_max=60');
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'items');
});

test('search filters by rating', function () {
    $response = $this->getJson('/api/v1/search/salons?rating_min=4.0');
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'items');
});

test('search filters by open now', function () {
    // Mock current time to Monday 10:00 AM
    $this->travelTo(now()->startOfWeek()->addDay()->setTime(10, 0));
    
    $response = $this->getJson('/api/v1/search/salons?open_now=1');
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'items');
});

test('search sorts by distance when coordinates provided', function () {
    $response = $this->getJson('/api/v1/search/salons?lat=52.5200&lng=13.4050&sort=distance');
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'items');
});

test('search pagination works', function () {
    $response = $this->getJson('/api/v1/search/salons?per_page=1');
    
    $response->assertStatus(200)
        ->assertJsonStructure([
            'pagination' => [
                'current_page',
                'per_page',
                'total',
                'next_page',
            ],
        ]);
});
