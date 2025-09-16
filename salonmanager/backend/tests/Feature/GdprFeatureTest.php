<?php

use App\Models\{Salon, User, GdprRequest};
use Illuminate\Support\Facades\Queue;
use App\Jobs\Gdpr\BuildExportJob;

it('creates export request and dispatches job', function () {
    $salon = Salon::factory()->create();
    app()->instance('tenant', $salon);
    $u = User::factory()->create(['current_salon_id' => $salon->id]);

    $this->actingAs($u, 'sanctum');
    Queue::fake();

    $res = $this->postJson('/api/v1/gdpr/export');
    $res->assertStatus(202)->assertJsonStructure(['gdpr_id', 'status']);

    Queue::assertPushed(BuildExportJob::class);
});

it('prevents downloading before done', function () {
    $salon = Salon::factory()->create();
    app()->instance('tenant', $salon);
    $u = User::factory()->create(['current_salon_id' => $salon->id]);
    $this->actingAs($u, 'sanctum');

    $g = GdprRequest::create([
        'salon_id' => $salon->id,
        'user_id' => $u->id,
        'type' => 'export',
        'status' => 'pending'
    ]);
    $this->getJson("/api/v1/gdpr/exports/{$g->id}/download")->assertStatus(404);
});

it('admin confirms deletion request', function () {
    $salon = Salon::factory()->create();
    app()->instance('tenant', $salon);
    $admin = User::factory()->create();
    // TODO(ASK): grant salon_owner role to $admin for $salon
    // $admin->grantRole('salon_owner', $salon->id);
    $this->actingAs($admin, 'sanctum');

    $victim = User::factory()->create(['current_salon_id' => $salon->id]);
    $g = GdprRequest::create([
        'salon_id' => $salon->id,
        'user_id' => $victim->id,
        'type' => 'delete',
        'status' => 'pending'
    ]);

    $this->postJson("/api/v1/gdpr/delete/{$g->id}/confirm")->assertStatus(200);
});