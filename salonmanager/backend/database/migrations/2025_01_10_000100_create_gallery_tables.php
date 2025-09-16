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
        // Gallery albums table
        Schema::create('gallery_albums', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->enum('visibility', ['public', 'private', 'unlisted'])->default('public');
            $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
            $table->timestamps();

            $table->index(['salon_id', 'visibility']);
            $table->index('created_by');
        });

        // Gallery photos table
        Schema::create('gallery_photos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained()->onDelete('cascade');
            $table->foreignId('album_id')->nullable()->constrained('gallery_albums')->onDelete('set null');
            $table->foreignId('customer_id')->nullable()->constrained('customer_profiles')->onDelete('set null');
            $table->string('path');
            $table->json('variants')->nullable(); // thumb, medium, web variants
            $table->uuid('before_after_group')->nullable(); // for before/after pairs
            $table->timestamp('approved_at')->nullable();
            $table->timestamp('rejected_at')->nullable();
            $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
            $table->timestamps();

            $table->index(['salon_id', 'album_id']);
            $table->index(['salon_id', 'approved_at']);
            $table->index('before_after_group');
            $table->index('created_by');
        });

        // Gallery consents table
        Schema::create('gallery_consents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained()->onDelete('cascade');
            $table->foreignId('customer_id')->nullable()->constrained('customer_profiles')->onDelete('set null');
            $table->foreignId('photo_id')->nullable()->constrained('gallery_photos')->onDelete('cascade');
            $table->enum('status', ['requested', 'approved', 'revoked'])->default('requested');
            $table->text('note')->nullable();
            $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
            $table->timestamps();

            $table->index(['salon_id', 'status']);
            $table->index(['customer_id', 'status']);
            $table->index('photo_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('gallery_consents');
        Schema::dropIfExists('gallery_photos');
        Schema::dropIfExists('gallery_albums');
    }
};
