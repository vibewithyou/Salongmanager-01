<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shifts', function (Blueprint $t) {
            $t->id();
            $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $t->foreignId('user_id')->constrained('users')->cascadeOnDelete(); // stylist
            $t->foreignId('stylist_id')->nullable()->constrained('stylists')->nullOnDelete();
            $t->dateTime('start_at');
            $t->dateTime('end_at');
            $t->string('role')->nullable(); // e.g. stylist, receptionist
            $t->string('title')->nullable();
            $t->string('status')->default('planned'); // planned, confirmed, swapped, canceled
            // Recurrence (RFC5545-lite)
            $t->string('rrule')->nullable(); // e.g. FREQ=WEEKLY;BYDAY=MO,TU;UNTIL=2025-12-31
            $t->json('exdates')->nullable(); // ISO dates excluded
            $t->boolean('published')->default(true);
            $t->json('meta')->nullable(); // additional metadata
            $t->timestamps();

            $t->index(['salon_id', 'user_id', 'start_at']);
            $t->index(['salon_id', 'stylist_id', 'start_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shifts');
    }
};
