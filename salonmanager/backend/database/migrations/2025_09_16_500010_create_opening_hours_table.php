<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('opening_hours', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->unsignedTinyInteger('weekday'); // 1=Mon .. 7=Sun
            $table->time('open_time');
            $table->time('close_time');
            $table->boolean('closed')->default(false);
            $table->timestamps();
            $table->unique(['salon_id','weekday']);
        });
    }
    public function down(): void { Schema::dropIfExists('opening_hours'); }
};