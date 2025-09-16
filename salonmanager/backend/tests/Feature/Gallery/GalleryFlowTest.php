<?php

use App\Models\User;
use App\Models\Salon;
use App\Models\GalleryAlbum;
use App\Models\GalleryPhoto;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->salon = Salon::factory()->create();
    $this->user = User::factory()->create([
        'current_salon_id' => $this->salon->id,
    ]);
    $this->user->assignRole('stylist');
    
    Storage::fake('public');
});

test('user can create gallery album', function () {
    $this->user->assignRole('salon_manager');
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/v1/gallery/albums', [
            'title' => 'Test Album',
            'visibility' => 'public',
        ]);
    
    $response->assertStatus(201)
        ->assertJson([
            'title' => 'Test Album',
            'visibility' => 'public',
        ]);
    
    $this->assertDatabaseHas('gallery_albums', [
        'title' => 'Test Album',
        'visibility' => 'public',
        'salon_id' => $this->salon->id,
    ]);
});

test('user can upload photo with consent', function () {
    $file = UploadedFile::fake()->image('test.jpg');
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/v1/gallery/photos', [
            'image' => $file,
            'consent_given' => true,
            'before_after_group' => 'test-group-123',
        ]);
    
    $response->assertStatus(201)
        ->assertJsonStructure([
            'id',
            'path',
            'before_after_group',
        ]);
    
    $this->assertDatabaseHas('gallery_photos', [
        'before_after_group' => 'test-group-123',
        'salon_id' => $this->salon->id,
    ]);
    
    $this->assertDatabaseHas('gallery_consents', [
        'status' => 'approved',
        'salon_id' => $this->salon->id,
    ]);
});

test('manager can moderate photos', function () {
    $this->user->assignRole('salon_manager');
    
    $photo = GalleryPhoto::factory()->create([
        'salon_id' => $this->salon->id,
        'created_by' => $this->user->id,
    ]);
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson("/api/v1/gallery/photos/{$photo->id}/moderate", [
            'action' => 'approve',
            'note' => 'Looks good!',
        ]);
    
    $response->assertStatus(200)
        ->assertJson(['message' => 'Photo approved successfully']);
    
    $photo->refresh();
    expect($photo->approved_at)->not->toBeNull();
    expect($photo->rejected_at)->toBeNull();
});

test('public can view approved photos', function () {
    $album = GalleryAlbum::factory()->create([
        'salon_id' => $this->salon->id,
        'visibility' => 'public',
    ]);
    
    $photo = GalleryPhoto::factory()->create([
        'salon_id' => $this->salon->id,
        'album_id' => $album->id,
        'approved_at' => now(),
    ]);
    
    $response = $this->getJson('/api/v1/gallery/photos?approved=1');
    
    $response->assertStatus(200)
        ->assertJsonCount(1, 'data');
});

test('before/after photos are grouped correctly', function () {
    $groupUuid = 'test-group-456';
    
    $photo1 = GalleryPhoto::factory()->create([
        'salon_id' => $this->salon->id,
        'before_after_group' => $groupUuid,
        'approved_at' => now(),
    ]);
    
    $photo2 = GalleryPhoto::factory()->create([
        'salon_id' => $this->salon->id,
        'before_after_group' => $groupUuid,
        'approved_at' => now(),
    ]);
    
    $response = $this->getJson("/api/v1/gallery/photos?before_after_group={$groupUuid}");
    
    $response->assertStatus(200)
        ->assertJsonCount(2, 'data');
});
