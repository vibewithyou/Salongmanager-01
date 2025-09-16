<?php

use App\Models\{Salon, User, Shift, Absence, WorkRule};
use App\Services\Schedule\{Recurrence, ConflictChecker, Rules};

it('creates a shift and lists expanded events', function () {
    $salon = Salon::factory()->create();
    app()->instance('tenant', $salon);
    
    $mgr = User::factory()->create();
    $mgr->grantRole('salon_manager', $salon->id);
    
    $sty = User::factory()->create(['salon_id' => $salon->id]);

    $this->actingAs($mgr, 'sanctum');
    
    // Create a recurring shift
    $this->postJson('/api/v1/schedule/shifts', [
        'user_id' => $sty->id,
        'start_at' => '2025-06-02T09:00:00Z',
        'end_at' => '2025-06-02T17:00:00Z',
        'title' => 'Test Shift',
        'role' => 'stylist',
        'rrule' => 'FREQ=WEEKLY;BYDAY=MO,TU;UNTIL=2025-07-31',
        'published' => true,
    ])->assertStatus(200);

    // List shifts in date range
    $res = $this->getJson('/api/v1/schedule/shifts?from=2025-06-01T00:00:00Z&to=2025-06-10T00:00:00Z');
    $res->assertStatus(200)->assertJson(fn ($j) => $j->has('items'));
    
    $items = $res->json('items');
    expect($items)->toHaveCount(2); // MO and TU of first week
});

it('creates an absence request and approves it', function () {
    $salon = Salon::factory()->create();
    app()->instance('tenant', $salon);
    
    $mgr = User::factory()->create();
    $mgr->grantRole('salon_manager', $salon->id);
    
    $sty = User::factory()->create(['salon_id' => $salon->id]);

    $this->actingAs($sty, 'sanctum');
    
    // Request absence
    $this->postJson('/api/v1/schedule/absences', [
        'user_id' => $sty->id,
        'start_at' => '2025-06-15T00:00:00Z',
        'end_at' => '2025-06-15T23:59:59Z',
        'from_date' => '2025-06-15',
        'to_date' => '2025-06-15',
        'type' => 'vacation',
        'reason' => 'Family vacation',
    ])->assertStatus(201);

    // Manager approves
    $this->actingAs($mgr, 'sanctum');
    $absence = Absence::where('salon_id', $salon->id)->first();
    
    $this->postJson("/api/v1/schedule/absences/{$absence->id}/decision", [
        'action' => 'approve',
        'reason' => 'Approved by manager',
    ])->assertStatus(200);
    
    $absence->refresh();
    expect($absence->status)->toBe('approved');
});

it('checks work rules validation', function () {
    $salon = Salon::factory()->create();
    app()->instance('tenant', $salon);
    
    // Create work rules
    WorkRule::create([
        'salon_id' => $salon->id,
        'max_hours_per_day' => 8,
        'min_break_minutes_per6h' => 30,
    ]);
    
    $mgr = User::factory()->create();
    $mgr->grantRole('salon_manager', $salon->id);
    
    $sty = User::factory()->create(['salon_id' => $salon->id]);

    $this->actingAs($mgr, 'sanctum');
    
    // Try to create a shift that violates work rules (10 hours)
    $this->postJson('/api/v1/schedule/shifts', [
        'user_id' => $sty->id,
        'start_at' => '2025-06-02T08:00:00Z',
        'end_at' => '2025-06-02T18:00:00Z', // 10 hours
        'title' => 'Long Shift',
    ])->assertStatus(422)
      ->assertJson(fn ($j) => $j->has('error', 'rule_violation'));
});

it('expands recurring shifts correctly', function () {
    $shift = new Shift([
        'start_at' => '2025-06-02T09:00:00Z',
        'end_at' => '2025-06-02T17:00:00Z',
        'rrule' => 'FREQ=WEEKLY;BYDAY=MO,TU;UNTIL=2025-06-30',
    ]);
    
    $from = \Carbon\Carbon::parse('2025-06-01');
    $to = \Carbon\Carbon::parse('2025-06-15');
    
    $expanded = Recurrence::expand($shift, $from, $to);
    
    expect($expanded)->toHaveCount(4); // 2 weeks * 2 days (MO, TU)
    
    // Check that all instances are on Monday or Tuesday
    foreach ($expanded as [$start, $end]) {
        expect($start->dayOfWeek)->toBeIn([1, 2]); // Monday=1, Tuesday=2
    }
});

it('detects booking conflicts', function () {
    $salon = Salon::factory()->create();
    $userId = 1;
    
    // Mock a booking in the database
    \DB::table('bookings')->insert([
        'salon_id' => $salon->id,
        'stylist_id' => $userId,
        'customer_id' => 1,
        'service_id' => 1,
        'start_at' => '2025-06-02T10:00:00Z',
        'end_at' => '2025-06-02T11:00:00Z',
        'status' => 'confirmed',
        'created_at' => now(),
        'updated_at' => now(),
    ]);
    
    $from = \Carbon\Carbon::parse('2025-06-02T09:00:00Z');
    $to = \Carbon\Carbon::parse('2025-06-02T12:00:00Z');
    
    $hasConflict = ConflictChecker::hasBookingConflict($salon->id, $userId, $from, $to);
    expect($hasConflict)->toBeTrue();
});

it('detects absence conflicts', function () {
    $salon = Salon::factory()->create();
    $userId = 1;
    
    // Mock an approved absence in the database
    \DB::table('absences')->insert([
        'salon_id' => $salon->id,
        'user_id' => $userId,
        'start_at' => '2025-06-02T08:00:00Z',
        'end_at' => '2025-06-02T18:00:00Z',
        'type' => 'vacation',
        'status' => 'approved',
        'created_at' => now(),
        'updated_at' => now(),
    ]);
    
    $from = \Carbon\Carbon::parse('2025-06-02T10:00:00Z');
    $to = \Carbon\Carbon::parse('2025-06-02T14:00:00Z');
    
    $hasConflict = ConflictChecker::hasAbsenceConflict($salon->id, $userId, $from, $to);
    expect($hasConflict)->toBeTrue();
});