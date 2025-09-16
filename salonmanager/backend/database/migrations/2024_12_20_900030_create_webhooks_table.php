<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('webhooks', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
      $t->string('event'); // booking.* , pos.invoice.paid , media.consent.requested ...
      $t->string('url');
      $t->string('secret')->nullable(); // optional HMAC
      $t->boolean('active')->default(true);
      $t->json('headers')->nullable();
      $t->timestamps();
      $t->unique(['salon_id','event','url']);
    });
  }
  public function down(): void { Schema::dropIfExists('webhooks'); }
};