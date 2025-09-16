<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],

    'allowed_origins' => ['https://salongmanager.app','http://localhost:*','http://127.0.0.1:*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['Content-Type','X-Requested-With','Authorization','X-Api-Scope'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => true,

];