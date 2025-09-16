<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('notification_logs', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
      $t->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
      $t->string('event');
      $t->string('channel'); // mail|sms|webhook
      $t->string('status');  // sent|skipped|failed
      $t->string('ref_type')->nullable(); // Invoice|Booking|MediaFile
      $t->unsignedBigInteger('ref_id')->nullable();
      $t->string('target')->nullable(); // email/phone/url
      $t->text('error')->nullable();
      $t->json('payload')->nullable();
      $t->timestamps();
      $t->index(['salon_id','event','channel','status']);
    });
  }
  public function down(): void { Schema::dropIfExists('notification_logs'); }
};