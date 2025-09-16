<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('salon_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->json('meta')->nullable(); // e.g., stylist specialties
            $table->timestamps();
            $table->unique(['salon_id','user_id']);
        });
    }
    public function down(): void {
        Schema::dropIfExists('salon_user');
    }
};

