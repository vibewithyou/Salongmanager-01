<?php
/*
 * Feature test to ensure healthcheck route responds correctly.
 */

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class HealthCheckTest extends TestCase
{
    // Note: In a full Laravel app, this extends the base TestCase with app bootstrapping.

    public function test_health_endpoint_returns_ok_with_version(): void
    {
        $response = $this->get('/api/v1/health');

        $response->assertStatus(200)
                 ->assertJson([
                     'status' => 'ok',
                     'version' => 'v1',
                 ]);
    }
}

