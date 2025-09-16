<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    if (!Schema::hasTable('idempotency_keys')) {
      Schema::create('idempotency_keys', function (Blueprint $t) {
        $t->id();
        $t->string('key')->unique();
        $t->string('scope')->nullable(); // e.g. stripe:webhook, mollie:webhook, pos:charge
        $t->timestamps();
      });
    }
    if (!Schema::hasTable('webhook_events')) {
      Schema::create('webhook_events', function (Blueprint $t) {
        $t->id();
        $t->string('provider');      // stripe|mollie
        $t->string('event_type');
        $t->string('external_id')->unique(); // event id or payment_intent id
        $t->json('payload');
        $t->timestamps();
        $t->index(['provider','event_type']);
      });
    }
  }
  public function down(): void {
    Schema::dropIfExists('webhook_events');
    Schema::dropIfExists('idempotency_keys');
  }
};
