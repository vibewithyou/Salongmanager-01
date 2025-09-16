<?php

return [
    'provider' => env('PAYMENT_PROVIDER', 'stripe'), // stripe|mollie
    'currency' => 'EUR',
    'tax_rates' => [
        'default' => 0.19,
        'reduced' => 0.07,
    ],
    'stripe' => [
        'secret_key' => env('STRIPE_SECRET_KEY'),
        'publishable_key' => env('STRIPE_PUBLISHABLE_KEY'),
        'webhook_secret' => env('STRIPE_WEBHOOK_SECRET'),
    ],
    'mollie' => [
        'api_key' => env('MOLLIE_API_KEY'),
        'webhook_url' => env('MOLLIE_WEBHOOK_URL'),
    ],
    'webhook_tolerance' => 300, // 5 minutes
];
