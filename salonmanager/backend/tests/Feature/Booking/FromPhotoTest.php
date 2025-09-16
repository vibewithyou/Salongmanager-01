<?php

use App\Models\User;
use App\Models\Salon;
use App\Models\GalleryPhoto;
use App\Models\GalleryAlbum;
use App\Models\Booking;
use App\Models\Service;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->salon = Salon::factory()->create();
    $this->customer = User::factory()->create([
        'current_salon_id' => $this->salon->id,
    ]);
    $this->customer->assignRole('customer');
    
    $this->service = Service::factory()->create([
        'salon_id' => $this->salon->id,
    ]);
    
    $this->album = GalleryAlbum::factory()->create([
        'salon_id' => $this->salon->id,
        'visibility' => 'public',
    ]);
    
    $this->photo = GalleryPhoto::factory()->create([
        'salon_id' => $this->salon->id,
        'album_id' => $this->album->id,
        'approved_at' => now(),
    ]);
});

test('customer can get suggested services for photo', function () {
    $response = $this->actingAs($this->customer, 'sanctum')
        ->getJson("/api/v1/bookings/from-photo/{$this->photo->id}/suggested-services");
    
    $response->assertStatus(200)
        ->assertJsonStructure([
            'suggested_services',
        ])
        ->assertHeader('X-AI', 'disabled'); // Null recommender returns disabled
});

test('customer can create booking from photo', function () {
    $response = $this->actingAs($this->customer, 'sanctum')
        ->postJson("/api/v1/bookings/from-photo/{$this->photo->id}", [
            'service_id' => $this->service->id,
            'start_at' => now()->addDays(1)->toISOString(),
        ]);
    
    $response->assertStatus(201)
        ->assertJsonStructure([
            'booking' => [
                'id',
                'service',
                'stylist',
            ],
            'next_steps' => [
                'message',
                'actions',
            ],
        ]);
    
    $this->assertDatabaseHas('bookings', [
        'salon_id' => $this->salon->id,
        'customer_id' => $this->customer->id,
        'service_id' => $this->service->id,
        'source' => 'photo:' . $this->photo->id,
        'status' => 'draft',
    ]);
});

test('booking from photo requires valid service', function () {
    $response = $this->actingAs($this->customer, 'sanctum')
        ->postJson("/api/v1/bookings/from-photo/{$this->photo->id}", [
            'service_id' => 999, // Non-existent service
        ]);
    
    $response->assertStatus(422)
        ->assertJsonValidationErrors(['service_id']);
});

test('booking from photo can include stylist', function () {
    $stylist = User::factory()->create([
        'current_salon_id' => $this->salon->id,
    ]);
    $stylist->assignRole('stylist');
    
    $response = $this->actingAs($this->customer, 'sanctum')
        ->postJson("/api/v1/bookings/from-photo/{$this->photo->id}", [
            'service_id' => $this->service->id,
            'stylist_id' => $stylist->id,
        ]);
    
    $response->assertStatus(201);
    
    $this->assertDatabaseHas('bookings', [
        'stylist_id' => $stylist->id,
    ]);
});

test('unauthenticated user cannot create booking from photo', function () {
    $response = $this->postJson("/api/v1/bookings/from-photo/{$this->photo->id}", [
        'service_id' => $this->service->id,
    ]);
    
    $response->assertStatus(401);
});

test('non-customer cannot create booking from photo', function () {
    $manager = User::factory()->create([
        'current_salon_id' => $this->salon->id,
    ]);
    $manager->assignRole('salon_manager');
    
    $response = $this->actingAs($manager, 'sanctum')
        ->postJson("/api/v1/bookings/from-photo/{$this->photo->id}", [
            'service_id' => $this->service->id,
        ]);
    
    $response->assertStatus(403);
});
