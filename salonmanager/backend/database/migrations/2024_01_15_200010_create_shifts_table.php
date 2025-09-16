<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('shifts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('stylist_id')->constrained('stylists')->cascadeOnDelete();
            $table->dateTime('start_at');
            $table->dateTime('end_at');
            $table->string('status')->default('planned'); // planned, confirmed, swapped, canceled
            $table->json('meta')->nullable(); // color, note etc.
            $table->timestamps();
            $table->index(['stylist_id', 'start_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shifts');
    }
};