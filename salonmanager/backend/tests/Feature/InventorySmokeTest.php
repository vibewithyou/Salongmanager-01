<?php

use Illuminate\Testing\Fluent\AssertableJson;

it('lists products via inventory api', function () {
    $user = \App\Models\User::factory()->create();
    // TODO(ASK: ensure user has salon & role permissions)
    $this->actingAs($user, 'sanctum');

    $res = $this->getJson('/api/v1/inventory/products');
    $res->assertStatus(200)->assertJson(fn(AssertableJson $j)=> $j->has('products'));
});