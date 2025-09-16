<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('notification_templates', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->nullable()->constrained('salons')->nullOnDelete(); // null = global default
      $t->string('event'); // booking.confirmed ...
      $t->string('channel'); // mail|sms|webhook
      $t->string('locale',5)->default('de');
      $t->string('subject')->nullable();     // mail only
      $t->text('body_markdown')->nullable(); // mail/sms body
      $t->text('webhook_json')->nullable();  // webhook payload template (mustache)
      $t->boolean('active')->default(true);
      $t->timestamps();
      $t->unique(['salon_id','event','channel','locale']);
    });
  }
  public function down(): void { Schema::dropIfExists('notification_templates'); }
};