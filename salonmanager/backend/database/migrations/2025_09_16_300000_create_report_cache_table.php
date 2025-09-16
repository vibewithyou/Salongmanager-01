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
        Schema::create('report_cache', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained()->cascadeOnDelete();
            $table->string('type'); // revenue, occupancy, top_services, top_stylists
            $table->json('payload');
            $table->date('date_from');
            $table->date('date_to');
            $table->timestamps();
            
            // Index for performance
            $table->index(['salon_id', 'type', 'date_from', 'date_to']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('report_cache');
    }
};