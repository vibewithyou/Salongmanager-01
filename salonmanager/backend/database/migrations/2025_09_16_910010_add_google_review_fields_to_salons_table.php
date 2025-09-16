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
        Schema::table('salons', function (Blueprint $table) {
            $table->string('google_place_id')->nullable()->after('country');
            $table->decimal('google_rating', 2, 1)->nullable()->after('google_place_id');
            $table->integer('google_ratings_total')->default(0)->after('google_rating');
            $table->timestamp('google_reviews_imported_at')->nullable()->after('google_ratings_total');
            
            $table->index('google_place_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('salons', function (Blueprint $table) {
            $table->dropColumn([
                'google_place_id',
                'google_rating',
                'google_ratings_total',
                'google_reviews_imported_at'
            ]);
        });
    }
};