<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('customer_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete(); // customer user
            $table->string('phone')->nullable();
            $table->string('preferred_stylist')->nullable();
            $table->json('prefs')->nullable(); // allergies, hair_type, etc.
            $table->json('address')->nullable(); // street/city/zip/country
            $table->timestamps();
            $table->unique(['salon_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_profiles');
    }
};