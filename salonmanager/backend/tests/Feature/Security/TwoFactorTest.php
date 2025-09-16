<?php

use App\Models\User;
use App\Models\Salon;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function () {
    $this->salon = Salon::factory()->create();
    $this->user = User::factory()->create([
        'current_salon_id' => $this->salon->id,
    ]);
});

test('admin user can enable 2FA', function () {
    $this->user->assignRole('salon_owner');
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/v1/auth/2fa/enable');
    
    $response->assertStatus(200)
        ->assertJsonStructure([
            'secret',
            'qr_code_url',
        ]);
    
    $this->user->refresh();
    expect($this->user->two_factor_secret)->not->toBeNull();
});

test('admin user can confirm 2FA', function () {
    $this->user->assignRole('salon_owner');
    
    // Enable 2FA first
    $enableResponse = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/v1/auth/2fa/enable');
    
    $secret = $enableResponse->json('secret');
    
    // Generate a valid TOTP code
    $google2fa = new \PragmaRX\Google2FA\Google2FA();
    $code = $google2fa->getCurrentOtp($secret);
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/v1/auth/2fa/confirm', [
            'code' => $code,
        ]);
    
    $response->assertStatus(200)
        ->assertJson(['message' => '2FA enabled successfully']);
    
    $this->user->refresh();
    expect($this->user->two_factor_confirmed_at)->not->toBeNull();
});

test('non-admin user cannot access 2FA endpoints', function () {
    $this->user->assignRole('customer');
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->postJson('/api/v1/auth/2fa/enable');
    
    $response->assertStatus(403);
});

test('2FA middleware blocks admin without 2FA', function () {
    $this->user->assignRole('salon_owner');
    
    // Set environment variable for required roles
    config(['app.two_fa_required_roles' => 'salon_owner,platform_admin']);
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/v1/salon/profile');
    
    $response->assertStatus(403)
        ->assertJson([
            'message' => 'Two-factor authentication is required for your role.',
            'requires_2fa' => true,
        ]);
});

test('2FA middleware allows admin with 2FA', function () {
    $this->user->assignRole('salon_owner');
    $this->user->update([
        'two_factor_confirmed_at' => now(),
    ]);
    
    $response = $this->actingAs($this->user, 'sanctum')
        ->getJson('/api/v1/salon/profile');
    
    $response->assertStatus(200);
});
