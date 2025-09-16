<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('customer_notes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('author_id')->constrained('users')->cascadeOnDelete(); // stylist/manager
            $table->text('note');
            $table->timestamps();
            $table->index(['customer_id', 'created_at']);
        });

        Schema::create('customer_media', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->string('path');     // TODO: real upload/storage
            $table->string('type')->default('image');
            $table->json('meta')->nullable(); // e.g., {alt, taken_at}
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_media');
        Schema::dropIfExists('customer_notes');
    }
};