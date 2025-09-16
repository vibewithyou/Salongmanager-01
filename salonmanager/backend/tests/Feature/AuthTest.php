<?php

use App\Models\User;
use App\Models\Salon;

beforeEach(function () {
    $this->salon = Salon::create([
        'name' => 'Test Salon',
        'slug' => 'test-salon',
        'primary_color' => '#000000',
        'secondary_color' => '#ffffff',
    ]);
});

it('can get access token with valid credentials', function () {
    $user = User::factory()->create([
        'email' => 'test@example.com',
        'password' => bcrypt('password'),
        'current_salon_id' => $this->salon->id,
    ]);

    $response = $this->postJson('/api/v1/auth/token', [
        'email' => 'test@example.com',
        'password' => 'password',
    ]);

    $response->assertOk()
        ->assertJsonStructure(['token', 'type'])
        ->assertJson(['type' => 'Bearer']);
});

it('cannot get access token with invalid credentials', function () {
    $response = $this->postJson('/api/v1/auth/token', [
        'email' => 'wrong@example.com',
        'password' => 'wrongpassword',
    ]);

    $response->assertStatus(422)
        ->assertJson(['message' => 'Invalid credentials']);
});

it('can login via spa cookie', function () {
    $user = User::factory()->create([
        'email' => 'spa@example.com',
        'password' => bcrypt('password'),
    ]);

    $response = $this->postJson('/api/v1/auth/login', [
        'email' => 'spa@example.com',
        'password' => 'password',
    ]);

    $response->assertOk()
        ->assertJson(['ok' => true]);
});

it('can get user info when authenticated', function () {
    $user = User::factory()->create([
        'current_salon_id' => $this->salon->id,
    ]);

    $response = $this->actingAs($user)
        ->withHeader('X-Salon-ID', $this->salon->id)
        ->getJson('/api/v1/auth/me');

    $response->assertOk()
        ->assertJsonStructure(['user', 'tenant'])
        ->assertJson([
            'user' => [
                'id' => $user->id,
                'email' => $user->email,
            ],
            'tenant' => [
                'id' => $this->salon->id,
                'slug' => $this->salon->slug,
            ],
        ]);
});

it('can logout', function () {
    $user = User::factory()->create();

    $response = $this->actingAs($user)
        ->postJson('/api/v1/auth/logout');

    $response->assertOk()
        ->assertJson(['ok' => true]);
});