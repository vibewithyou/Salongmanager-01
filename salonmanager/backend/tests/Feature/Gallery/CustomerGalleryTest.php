<?php

use App\Models\User;
use App\Models\Salon;
use App\Models\CustomerProfile;
use App\Models\GalleryPhoto;
use App\Models\GalleryAlbum;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->salon = Salon::factory()->create();
    $this->customer = CustomerProfile::factory()->create([
        'salon_id' => $this->salon->id,
    ]);
    $this->otherCustomer = CustomerProfile::factory()->create([
        'salon_id' => $this->salon->id,
    ]);
    
    $this->manager = User::factory()->create([
        'current_salon_id' => $this->salon->id,
    ]);
    $this->manager->assignRole('salon_manager');
    
    $this->stylist = User::factory()->create([
        'current_salon_id' => $this->salon->id,
    ]);
    $this->stylist->assignRole('stylist');
    
    $this->album = GalleryAlbum::factory()->create([
        'salon_id' => $this->salon->id,
        'visibility' => 'private_customer',
    ]);
    
    $this->photo = GalleryPhoto::factory()->create([
        'salon_id' => $this->salon->id,
        'album_id' => $this->album->id,
        'customer_id' => $this->customer->id,
        'approved_at' => now(),
    ]);
});

test('customer can view their own gallery', function () {
    $response = $this->actingAs($this->customer, 'sanctum')
        ->getJson("/api/v1/customers/{$this->customer->id}/gallery");
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'data');
});

test('manager can view customer gallery', function () {
    $response = $this->actingAs($this->manager, 'sanctum')
        ->getJson("/api/v1/customers/{$this->customer->id}/gallery");
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'data');
});

test('stylist can view customer gallery', function () {
    $response = $this->actingAs($this->stylist, 'sanctum')
        ->getJson("/api/v1/customers/{$this->customer->id}/gallery");
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'data');
});

test('customer cannot view other customer gallery', function () {
    $response = $this->actingAs($this->otherCustomer, 'sanctum')
        ->getJson("/api/v1/customers/{$this->customer->id}/gallery");
    
    $response->assertStatus(403);
});

test('unauthenticated user cannot view customer gallery', function () {
    $response = $this->getJson("/api/v1/customers/{$this->customer->id}/gallery");
    
    $response->assertStatus(401);
});

test('customer gallery filters by approval status', function () {
    // Create an unapproved photo
    GalleryPhoto::factory()->create([
        'salon_id' => $this->salon->id,
        'album_id' => $this->album->id,
        'customer_id' => $this->customer->id,
        'approved_at' => null,
    ]);
    
    // Test approved only
    $response = $this->actingAs($this->customer, 'sanctum')
        ->getJson("/api/v1/customers/{$this->customer->id}/gallery?approved=1");
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'data');
    
    // Test all photos (customer can see their own unapproved)
    $response = $this->actingAs($this->customer, 'sanctum')
        ->getJson("/api/v1/customers/{$this->customer->id}/gallery");
    
    $response->assertStatus(200)
        ->assertJsonCount(2, 'data');
});

test('staff only see approved photos in customer gallery', function () {
    // Create an unapproved photo
    GalleryPhoto::factory()->create([
        'salon_id' => $this->salon->id,
        'album_id' => $this->album->id,
        'customer_id' => $this->customer->id,
        'approved_at' => null,
    ]);
    
    $response = $this->actingAs($this->manager, 'sanctum')
        ->getJson("/api/v1/customers/{$this->customer->id}/gallery");
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'data'); // Only the approved photo
});
