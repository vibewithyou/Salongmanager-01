<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;

class SecurityAudit extends Command {
  protected $signature = 'audit:security';
  protected $description = 'Check CSP middleware, throttle alias, and webhook secrets presence';
  public function handle(): int {
    $okCsp = class_exists(\App\Http\Middleware\SecureHeaders::class);
    $okThrottle = array_key_exists('throttle.scope', app(\App\Http\Kernel::class)->getRouteMiddleware());
    $stripe = env('STRIPE_WEBHOOK_SECRET');
    $mollie = env('MOLLIE_KEY');
    @mkdir(base_path('../ops/audit'),0777,true);
    $lines = [
      'CSP_middleware='.($okCsp?'OK':'MISSING'),
      'Throttle_scope_alias='.($okThrottle?'OK':'MISSING'),
      'Stripe_webhook_secret='.($stripe?'SET':'MISSING'),
      'Mollie_key='.($mollie?'SET':'MISSING'),
    ];
    file_put_contents(base_path('../ops/audit/security.txt'), implode("\n",$lines));
    $this->info(implode(" | ",$lines));
    return self::SUCCESS;
  }
}
