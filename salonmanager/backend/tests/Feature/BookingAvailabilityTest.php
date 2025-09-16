<?php

use App\Services\Booking\AvailabilityService;
use Illuminate\Support\Carbon;

it('rejects overlapping booking and provides suggestions', function () {
  $salon = \App\Models\Salon::factory()->create();
  app()->instance('tenant', $salon);
  $stylist = \App\Models\User::factory()->create(['salon_id'=>$salon->id]);
  $customer = \App\Models\User::factory()->create(['salon_id'=>$salon->id]);
  $service = \App\Models\Service::factory()->create(['salon_id'=>$salon->id]);

  // bestehende Buchung 10:00–10:30
  \App\Models\Booking::factory()->create([
    'salon_id'=>$salon->id,
    'stylist_id'=>$stylist->id,
    'customer_id'=>$customer->id,
    'service_id'=>$service->id,
    'start_at'=>Carbon::parse('2025-06-01 10:00:00'),
    'end_at'=>Carbon::parse('2025-06-01 10:30:00'),
    'status'=>'confirmed'
  ]);

  $start = Carbon::parse('2025-06-01 10:15:00');
  $free = AvailabilityService::isFree($salon->id,$stylist->id,$start,30,0,0);
  expect($free)->toBeFalse();

  // API erwartet 409 + suggestions
  $this->actingAs($customer,'sanctum');
  $res = $this->postJson('/api/v1/bookings', [
    'customer_id'=>$customer->id,
    'stylist_id'=>$stylist->id,
    'service_id'=>$service->id,
    'start_at'=>$start->toIso8601String(),
    'duration'=>30,
    'suggest_if_conflict'=>true
  ]);
  $res->assertStatus(409)->assertJson(fn($j)=>$j->has('suggestions'));
});

it('checks opening hours for availability', function () {
  $salon = \App\Models\Salon::factory()->create();
  app()->instance('tenant', $salon);
  $stylist = \App\Models\User::factory()->create(['salon_id'=>$salon->id]);

  // Create opening hours (Monday 09:00-18:00)
  \DB::table('opening_hours')->insert([
    'salon_id' => $salon->id,
    'weekday' => 1, // Monday
    'open_at' => '09:00:00',
    'close_at' => '18:00:00',
  ]);

  // Test booking outside opening hours
  $earlyStart = Carbon::parse('next monday')->setTime(8, 0);
  $free = AvailabilityService::isFree($salon->id, $stylist->id, $earlyStart, 60, 0, 0);
  expect($free)->toBeFalse();

  // Test booking within opening hours
  $validStart = Carbon::parse('next monday')->setTime(10, 0);
  $free = AvailabilityService::isFree($salon->id, $stylist->id, $validStart, 60, 0, 0);
  expect($free)->toBeTrue();
});

it('checks stylist absences for availability', function () {
  $salon = \App\Models\Salon::factory()->create();
  app()->instance('tenant', $salon);
  $stylist = \App\Models\User::factory()->create(['salon_id'=>$salon->id]);

  // Create absence for stylist
  \DB::table('absences')->insert([
    'salon_id' => $salon->id,
    'user_id' => $stylist->id,
    'start_at' => Carbon::parse('2025-06-01 10:00:00'),
    'end_at' => Carbon::parse('2025-06-01 14:00:00'),
    'reason' => 'Lunch break',
  ]);

  // Test booking during absence
  $duringAbsence = Carbon::parse('2025-06-01 11:00:00');
  $free = AvailabilityService::isFree($salon->id, $stylist->id, $duringAbsence, 60, 0, 0);
  expect($free)->toBeFalse();

  // Test booking after absence
  $afterAbsence = Carbon::parse('2025-06-01 15:00:00');
  $free = AvailabilityService::isFree($salon->id, $stylist->id, $afterAbsence, 60, 0, 0);
  expect($free)->toBeTrue();
});

it('respects buffer times when checking availability', function () {
  $salon = \App\Models\Salon::factory()->create();
  app()->instance('tenant', $salon);
  $stylist = \App\Models\User::factory()->create(['salon_id'=>$salon->id]);
  $service = \App\Models\Service::factory()->create(['salon_id'=>$salon->id]);

  // Existing booking 10:00-10:30
  \App\Models\Booking::factory()->create([
    'salon_id'=>$salon->id,
    'stylist_id'=>$stylist->id,
    'service_id'=>$service->id,
    'start_at'=>Carbon::parse('2025-06-01 10:00:00'),
    'end_at'=>Carbon::parse('2025-06-01 10:30:00'),
    'status'=>'confirmed'
  ]);

  // Test booking right after without buffer - should work
  $withoutBuffer = Carbon::parse('2025-06-01 10:30:00');
  $free = AvailabilityService::isFree($salon->id, $stylist->id, $withoutBuffer, 30, 0, 0);
  expect($free)->toBeTrue();

  // Test booking right after with 15min buffer before - should fail
  $withBuffer = Carbon::parse('2025-06-01 10:40:00');
  $free = AvailabilityService::isFree($salon->id, $stylist->id, $withBuffer, 30, 15, 0);
  expect($free)->toBeFalse();

  // Test booking with enough gap for buffer - should work
  $withEnoughGap = Carbon::parse('2025-06-01 10:45:00');
  $free = AvailabilityService::isFree($salon->id, $stylist->id, $withEnoughGap, 30, 15, 0);
  expect($free)->toBeTrue();
});