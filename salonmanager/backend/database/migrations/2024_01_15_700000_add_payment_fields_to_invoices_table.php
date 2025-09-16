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
        Schema::table('invoices', function (Blueprint $table) {
            $table->string('payment_id')->nullable()->after('status');
            $table->string('payment_provider')->nullable()->after('payment_id');
            
            // Add index for payment lookups
            $table->index(['payment_id', 'payment_provider']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('invoices', function (Blueprint $table) {
            $table->dropIndex(['payment_id', 'payment_provider']);
            $table->dropColumn(['payment_id', 'payment_provider']);
        });
    }
};
