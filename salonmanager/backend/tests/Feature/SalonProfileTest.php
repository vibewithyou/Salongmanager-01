<?php

it('reads salon profile public', function () {
    // TODO: create salon + bind tenant; GET /api/v1/salon/profile with header X-Salon-Slug
    expect(true)->toBeTrue(); // placeholder until factories exist
})->todo();

it('blocks profile update for non-privileged', function () {
    // TODO: user without role salon_owner/manager; expect 403
})->todo();