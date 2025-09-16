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
        Schema::table('gallery_photos', function (Blueprint $table) {
            // Add customer_id if it doesn't exist (it should already exist based on the original migration)
            if (!Schema::hasColumn('gallery_photos', 'customer_id')) {
                $table->foreignId('customer_id')->nullable()->constrained('customer_profiles')->onDelete('set null');
            }
            
            // Add index for customer_id
            $table->index('customer_id');
        });

        // Update gallery_albums visibility enum to include private_customer
        Schema::table('gallery_albums', function (Blueprint $table) {
            $table->enum('visibility', ['public', 'private', 'unlisted', 'private_customer'])->default('public')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('gallery_albums', function (Blueprint $table) {
            $table->enum('visibility', ['public', 'private', 'unlisted'])->default('public')->change();
        });

        Schema::table('gallery_photos', function (Blueprint $table) {
            $table->dropIndex(['customer_id']);
            // Note: We don't drop the customer_id column as it was in the original migration
        });
    }
};
