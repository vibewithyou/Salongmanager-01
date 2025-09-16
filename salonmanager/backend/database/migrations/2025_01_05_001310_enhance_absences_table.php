<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('absences', function (Blueprint $table) {
            // Add user_id field for direct user relationship
            $table->foreignId('user_id')->nullable()->after('stylist_id')->constrained('users')->cascadeOnDelete();
            
            // Change date fields to datetime for more precise scheduling
            $table->dateTime('start_at')->nullable()->after('user_id');
            $table->dateTime('end_at')->nullable()->after('start_at');
            
            // Add reason field for detailed absence information
            $table->text('reason')->nullable()->after('note');
            
            // Update status values
            $table->string('status')->default('pending')->change(); // pending, approved, rejected
            
            // Update indexes
            $table->index(['salon_id', 'user_id', 'start_at', 'status']);
        });
    }

    public function down(): void
    {
        Schema::table('absences', function (Blueprint $table) {
            $table->dropIndex(['salon_id', 'user_id', 'start_at', 'status']);
            $table->dropColumn(['user_id', 'start_at', 'end_at', 'reason']);
            $table->string('status')->default('requested')->change();
        });
    }
};
