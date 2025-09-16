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
        Schema::create('media_files', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->morphs('owner'); // owner_type/id: User, GalleryPhoto, CustomerProfile etc.
            $table->string('disk')->default('media');
            $table->string('path');            // original object key
            $table->string('mime')->nullable();
            $table->unsignedBigInteger('bytes')->default(0);
            $table->unsignedInteger('width')->nullable();
            $table->unsignedInteger('height')->nullable();
            $table->json('variants')->nullable(); // {thumb:"...", webp:"..."}
            $table->json('exif')->nullable();
            // DSGVO / Consent
            $table->boolean('consent_required')->default(false);
            $table->string('consent_status')->default('unknown'); // unknown|requested|approved|revoked
            $table->foreignId('subject_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('subject_name')->nullable();
            $table->string('subject_contact')->nullable();
            $table->date('retention_until')->nullable();
            $table->string('visibility')->default('internal'); // public|internal|private
            $table->timestamps();
            $table->softDeletes();
            $table->index(['salon_id', 'visibility']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('media_files');
    }
};