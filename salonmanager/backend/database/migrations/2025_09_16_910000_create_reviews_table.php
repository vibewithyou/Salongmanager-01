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
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete(); // author
            $table->unsignedTinyInteger('rating'); // 1-5
            $table->text('body')->nullable();
            $table->json('media_ids')->nullable(); // optional Bild-IDs
            $table->string('source')->default('local'); // local|google
            $table->string('source_id')->nullable(); // Google review id
            $table->string('author_name')->nullable(); // falls source=google oder Gast
            $table->boolean('approved')->default(true); // moderation flag
            $table->timestamps();
            $table->index(['salon_id', 'source']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};