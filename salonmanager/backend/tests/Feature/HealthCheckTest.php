<?php

it('returns ok for health', function () {
    $response = $this->getJson('/api/v1/health');
    $response->assertOk()->assertJson(fn($json) =>
        $json->where('status', 'ok')->where('version', 'v1')->etc()
    );
});