<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::table('bookings', function (Blueprint $t) {
      $t->unsignedInteger('buffer_before')->default(0)->after('end_at'); // minutes
      $t->unsignedInteger('buffer_after')->default(0)->after('buffer_before');  // minutes
      $t->text('note')->nullable()->after('notes');
      $t->unsignedBigInteger('service_id')->nullable()->after('stylist_id');
      $t->unsignedInteger('duration')->nullable()->after('end_at'); // minutes
    });
    
    if (!Schema::hasTable('booking_media')) {
      Schema::create('booking_media', function (Blueprint $t) {
        $t->id();
        $t->foreignId('booking_id')->constrained('bookings')->cascadeOnDelete();
        $t->foreignId('media_file_id')->constrained('media_files')->cascadeOnDelete();
        $t->timestamps();
        $t->unique(['booking_id','media_file_id']);
      });
    }
  }
  
  public function down(): void {
    Schema::dropIfExists('booking_media');
    Schema::table('bookings', function (Blueprint $t) {
      $t->dropColumn(['buffer_before','buffer_after','note','service_id','duration']);
    });
  }
};