<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('shifts', function (Blueprint $table) {
            // Add new fields for enhanced scheduling
            $table->foreignId('user_id')->nullable()->after('stylist_id')->constrained('users')->cascadeOnDelete();
            $table->string('role')->nullable()->after('user_id'); // e.g. stylist, receptionist
            $table->string('title')->nullable()->after('role');
            
            // Recurrence support (RFC5545-lite)
            $table->string('rrule')->nullable()->after('title'); // e.g. FREQ=WEEKLY;BYDAY=MO,TU;UNTIL=2025-12-31
            $table->json('exdates')->nullable()->after('rrule'); // ISO dates excluded
            $table->boolean('published')->default(true)->after('exdates');
            
            // Update indexes
            $table->index(['salon_id', 'user_id', 'start_at']);
        });
    }

    public function down(): void
    {
        Schema::table('shifts', function (Blueprint $table) {
            $table->dropIndex(['salon_id', 'user_id', 'start_at']);
            $table->dropColumn([
                'user_id', 'role', 'title', 'rrule', 'exdates', 'published'
            ]);
        });
    }
};
