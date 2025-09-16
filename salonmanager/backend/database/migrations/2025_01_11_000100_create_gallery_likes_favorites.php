<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Gallery likes table
        Schema::create('gallery_likes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('photo_id')->constrained('gallery_photos')->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            // Unique constraint to prevent duplicate likes
            $table->unique(['photo_id', 'user_id']);
            
            // Indexes for performance
            $table->index('salon_id');
            $table->index('photo_id');
            $table->index('user_id');
        });

        // Gallery favorites table
        Schema::create('gallery_favorites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('photo_id')->constrained('gallery_photos')->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            // Unique constraint to prevent duplicate favorites
            $table->unique(['photo_id', 'user_id']);
            
            // Indexes for performance
            $table->index('salon_id');
            $table->index('photo_id');
            $table->index('user_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('gallery_favorites');
        Schema::dropIfExists('gallery_likes');
    }
};
