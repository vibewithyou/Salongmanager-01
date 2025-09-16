<?php

it('assigns and checks roles in tenant scope', function () {
  $salon = \App\Models\Salon::factory()->create();
  app()->instance('tenant', $salon);
  $u = \App\Models\User::factory()->create();

  // seed roles first in your test suite or call seeder here
  // \Database\Seeders\RoleSeeder::run(); // if accessible, else ensure roles exist

  $u->grantRole('customer', $salon->id);
  expect($u->hasRole('customer', $salon->id))->toBeTrue();
  expect($u->hasRole('customer', $salon->id + 1))->toBeFalse();

  $u->grantRole('owner'); // global
  expect($u->hasRole('salon_manager', $salon->id))->toBeTrue(); // owner short-circuit
});