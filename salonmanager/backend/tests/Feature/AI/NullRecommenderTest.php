<?php

use App\Models\User;
use App\Models\Salon;
use App\Models\GalleryPhoto;
use App\Models\GalleryAlbum;
use App\Services\Gallery\AI\NullRecommender;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->salon = Salon::factory()->create();
    $this->user = User::factory()->create([
        'current_salon_id' => $this->salon->id,
    ]);
    $this->user->assignRole('customer');
    
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

test('null recommender returns empty array', function () {
    $recommender = new NullRecommender();
    $suggestions = $recommender->suggestServicesForPhoto($this->photo->id);
    
    expect($suggestions)->toBeArray();
    expect($suggestions)->toBeEmpty();
});

test('suggested services endpoint returns disabled header', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson("/api/v1/gallery/photos/{$this->photo->id}/suggested-services");
    
    $response->assertStatus(200)
        ->assertJson([
            'suggested_services' => [],
        ])
        ->assertHeader('X-AI', 'disabled');
});

test('booking suggested services endpoint returns disabled header', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson("/api/v1/bookings/from-photo/{$this->photo->id}/suggested-services");
    
    $response->assertStatus(200)
        ->assertJson([
            'suggested_services' => [],
        ])
        ->assertHeader('X-AI', 'disabled');
});
