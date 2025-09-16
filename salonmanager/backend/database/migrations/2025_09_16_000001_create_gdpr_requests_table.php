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
        Schema::create('gdpr_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('type'); // export|delete
            $table->string('status')->default('pending'); // pending|processing|done|denied|failed
            $table->string('artifact_path')->nullable(); // exports/tenant/.../gdpr_{id}.zip
            $table->json('meta')->nullable(); // sizes, counts ...
            $table->timestamps();

            $table->index(['salon_id', 'user_id', 'type', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('gdpr_requests');
    }
};