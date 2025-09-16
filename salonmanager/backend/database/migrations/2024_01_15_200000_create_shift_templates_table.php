<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('shift_templates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->string('name'); // z.B. "Frühschicht"
            $table->unsignedTinyInteger('weekday')->nullable(); // 1=Mon..7=Son (optional)
            $table->time('start_time');
            $table->time('end_time');
            $table->json('meta')->nullable(); // z.B. Farbe
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shift_templates');
    }
};