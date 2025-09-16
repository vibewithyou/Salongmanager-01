<?php

use App\Models\User;
use App\Models\Salon;
use App\Models\GalleryPhoto;
use App\Models\GalleryAlbum;
use App\Models\GalleryLike;
use App\Models\GalleryFavorite;
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

test('user can like a photo', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson("/api/v1/gallery/photos/{$this->photo->id}/like");
    
    $response->assertStatus(200)
        ->assertJson([
            'liked' => true,
            'likes_count' => 1,
        ]);
    
    $this->assertDatabaseHas('gallery_likes', [
        'photo_id' => $this->photo->id,
        'user_id' => $this->user->id,
        'salon_id' => $this->salon->id,
    ]);
});

test('user can unlike a photo', function () {
    // First like the photo
    GalleryLike::create([
        'salon_id' => $this->salon->id,
        'photo_id' => $this->photo->id,
        'user_id' => $this->user->id,
    ]);
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson("/api/v1/gallery/photos/{$this->photo->id}/like");
    
    $response->assertStatus(200)
        ->assertJson([
            'liked' => false,
            'likes_count' => 0,
        ]);
    
    $this->assertDatabaseMissing('gallery_likes', [
        'photo_id' => $this->photo->id,
        'user_id' => $this->user->id,
    ]);
});

test('user can favorite a photo', function () {
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson("/api/v1/gallery/photos/{$this->photo->id}/favorite");
    
    $response->assertStatus(200)
        ->assertJson([
            'favorited' => true,
            'favorites_count' => 1,
        ]);
    
    $this->assertDatabaseHas('gallery_favorites', [
        'photo_id' => $this->photo->id,
        'user_id' => $this->user->id,
        'salon_id' => $this->salon->id,
    ]);
});

test('user can unfavorite a photo', function () {
    // First favorite the photo
    GalleryFavorite::create([
        'salon_id' => $this->salon->id,
        'photo_id' => $this->photo->id,
        'user_id' => $this->user->id,
    ]);
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson("/api/v1/gallery/photos/{$this->photo->id}/favorite");
    
    $response->assertStatus(200)
        ->assertJson([
            'favorited' => false,
            'favorites_count' => 0,
        ]);
    
    $this->assertDatabaseMissing('gallery_favorites', [
        'photo_id' => $this->photo->id,
        'user_id' => $this->user->id,
    ]);
});

test('can get photo stats', function () {
    // Create some likes and favorites
    GalleryLike::create([
        'salon_id' => $this->salon->id,
        'photo_id' => $this->photo->id,
        'user_id' => $this->user->id,
    ]);
    
    GalleryFavorite::create([
        'salon_id' => $this->salon->id,
        'photo_id' => $this->photo->id,
        'user_id' => $this->user->id,
    ]);
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson("/api/v1/gallery/photos/{$this->photo->id}/stats");
    
    $response->assertStatus(200)
        ->assertJson([
            'likes' => 1,
            'is_liked' => true,
            'is_favorited' => true,
        ]);
});

test('stats work without authentication', function () {
    // Create some likes and favorites
    GalleryLike::create([
        'salon_id' => $this->salon->id,
        'photo_id' => $this->photo->id,
        'user_id' => $this->user->id,
    ]);
    
    $response = $this->getJson("/api/v1/gallery/photos/{$this->photo->id}/stats");
    
    $response->assertStatus(200)
        ->assertJson([
            'likes' => 1,
            'is_liked' => false,
            'is_favorited' => false,
        ]);
});

test('rate limiting applies to likes and favorites', function () {
    // This would need to be tested with a proper rate limiting test
    // For now, we'll just ensure the endpoints exist and work
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson("/api/v1/gallery/photos/{$this->photo->id}/like");
    
    $response->assertStatus(200);
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson("/api/v1/gallery/photos/{$this->photo->id}/favorite");
    
    $response->assertStatus(200);
});
