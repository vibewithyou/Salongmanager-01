<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('notification_settings', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
      $t->foreignId('user_id')->constrained('users')->cascadeOnDelete();
      $t->string('event');   // booking.confirmed, booking.declined, booking.canceled, pos.invoice.paid, media.consent.requested ...
      $t->string('channel'); // mail|sms|webhook|push (push reserviert)
      $t->boolean('enabled')->default(true);
      $t->json('meta')->nullable(); // z. B. webhook target override für user
      $t->timestamps();
      $t->unique(['user_id','event','channel']);
    });
  }
  public function down(): void { Schema::dropIfExists('notification_settings'); }
};