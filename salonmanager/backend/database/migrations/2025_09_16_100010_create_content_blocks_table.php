<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('content_blocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->string('type');          // hero, text, gallery, cta, custom-*
            $table->string('title')->nullable();
            $table->json('config')->nullable();  // per type config (e.g., text HTML, images[], button)
            $table->boolean('is_active')->default(true);
            $table->unsignedInteger('position')->default(0); // ordering
            $table->timestamps();
        });
        
        // Optional: lightweight media table stub for future asset mgmt
        Schema::create('content_media', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->string('path'); // TODO: move to proper media manager later
            $table->json('meta')->nullable(); // alt, caption, focal point
            $table->timestamps();
        });
    }
    
    public function down(): void {
        Schema::dropIfExists('content_media');
        Schema::dropIfExists('content_blocks');
    }
};