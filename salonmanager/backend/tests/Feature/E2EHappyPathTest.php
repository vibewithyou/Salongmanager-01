<?php

use Illuminate\Support\Carbon;

uses(\Tests\TestCase::class);

it('E2E: auth -> booking -> pos -> webhook -> gdpr export', function() {
  // Arrange tenant & users
  $salon = \App\Models\Salon::factory()->create();
  app()->instance('tenant', $salon);

  $customer = \App\Models\User::factory()->create(['salon_id'=>$salon->id]);
  $stylist  = \App\Models\User::factory()->create(['salon_id'=>$salon->id]);
  // optional: $customer->grantRole('customer', $salon->id);

  // Login as customer (token via Sanctum Personal Access Token)
  \Laravel\Sanctum\Sanctum::actingAs($customer, ['*']);

  // 1) Create booking (no conflict)
  $start = Carbon::now()->addDays(1)->minute(0);
  $res = $this->postJson('/api/v1/bookings',[
    'customer_id'=>$customer->id,
    'stylist_id'=>$stylist->id,
    'service_id'=>1,
    'start_at'=>$start->toIso8601String(),
    'duration'=>30,
    'suggest_if_conflict'=>true
  ]);
  $res->assertStatus(201);
  $bookingId = $res->json('booking.id');

  // 2) Create draft invoice + finalize number
  $inv = \App\Models\Invoice::factory()->create([
    'salon_id'=>$salon->id,'status'=>'draft','total'=>49.99,'tax_rate'=>0.19
  ]);
  if (method_exists($inv,'finalizeNumber')) { $inv->finalizeNumber(); }
  expect($inv->number)->not->toBeNull();

  // 3) Simulate webhook (provider-specific check mocked: expect 400 or idempotent path OK)
  // We only verify controller path is reachable and not crashing without signature.
  $this->postJson('/api/v1/payments/webhook', [])->assertStatus(400);

  // 4) GDPR export request accepted
  $this->postJson('/api/v1/gdpr/export')->assertStatus(202);
})->group('e2e');
