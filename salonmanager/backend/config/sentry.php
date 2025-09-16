<?php

return [
    'dsn' => env('SENTRY_LARAVEL_DSN', env('SENTRY_DSN')),
    'release' => env('SENTRY_RELEASE'),
    'environment' => env('APP_ENV', 'production'),
    'traces_sample_rate' => (float) env('SENTRY_TRACES_SAMPLE_RATE', 0.0),
    'profiles_sample_rate' => (float) env('SENTRY_PROFILES_SAMPLE_RATE', 0.0),
    'send_default_pii' => false,
    'attach_stacktrace' => true,
    'context_lines' => 5,
    'enable_compression' => true,
    'before_send' => function (\Sentry\Event $event, ?\Sentry\EventHint $hint): ?\Sentry\Event {
        return $event;
    },
    'before_send_transaction' => function (\Sentry\Event $event, ?\Sentry\EventHint $hint): ?\Sentry\Event {
        return $event;
    },
    'integrations' => [
        new \Sentry\Integration\LaravelIntegration(),
        new \Sentry\Integration\LumenIntegration(),
        new \Sentry\Integration\RequestIntegration(),
        new \Sentry\Integration\TransactionIntegration(),
        new \Sentry\Integration\FrameContextifierIntegration(),
        new \Sentry\Integration\BreadcrumbIntegration(),
        new \Sentry\Integration\RequestContextIntegration(),
    ],
    'default_integrations' => true,
    'max_breadcrumbs' => 50,
    'before_breadcrumb' => function (\Sentry\Breadcrumb $breadcrumb, ?\Sentry\EventHint $hint): ?\Sentry\Breadcrumb {
        return $breadcrumb;
    },
    'in_app_exclude' => [
        'vendor/',
    ],
    'in_app_include' => [
        'app/',
    ],
    'send_attempts' => 3,
    'prefixes' => [
        base_path(),
    ],
    'sample_rate' => 1.0,
    'error_types' => E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED,
    'max_value_length' => 1024,
    'http_proxy' => env('SENTRY_HTTP_PROXY'),
    'http_timeout' => 2.0,
    'http_retry_attempts' => 3,
    'http_retry_interval' => 100,
    'capture_silenced_errors' => false,
    'max_request_body_size' => 'none',
    'class_serializers' => [
        // Add custom class serializers here
    ],
];
