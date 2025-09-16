<?php

use App\Support\Audit\Audit;
use App\Models\AuditLog;

it('writes audit entries with request context', function () {
    $salon = \App\Models\Salon::factory()->create();
    app()->instance('tenant', $salon);

    $u = \App\Models\User::factory()->create(['salon_id'=>$salon->id]);
    $this->actingAs($u, 'sanctum');

    // fake request
    $this->getJson('/api/health'); // beliebige Route, um Request-Kontext zu haben
    Audit::write('test.action','Foo',123,['k'=>'v']);

    $row = AuditLog::latest()->first();
    expect($row->action)->toBe('test.action')
        ->and($row->entity_type)->toBe('Foo')
        ->and($row->entity_id)->toBe(123)
        ->and($row->salon_id)->toBe($salon->id)
        ->and($row->user_id)->toBe($u->id)
        ->and($row->ip)->not->toBeNull();
});