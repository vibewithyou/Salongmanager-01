<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void {
        Schema::table('salons', function (Blueprint $table) {
            $table->string('short_desc')->nullable();
            $table->json('tags')->nullable(); // ["balayage","barber","kids",...]
            // MySQL 8: POINT with SRID 4326
            $table->point('location')->nullable()->srid(4326);
            $table->string('address_line1')->nullable();
            $table->string('address_line2')->nullable();
            $table->string('city')->nullable();
            $table->string('zip')->nullable();
            $table->string('country')->nullable();
        });

        // Indizes
        DB::statement('CREATE SPATIAL INDEX salons_location_spx ON salons (location)');
        Schema::table('salons', function (Blueprint $table) {
            $table->index('city');
            $table->index('zip');
        });
    }

    public function down(): void {
        Schema::table('salons', function (Blueprint $table) {
            $table->dropIndex('salons_location_spx');
            $table->dropIndex(['city']);
            $table->dropIndex(['zip']);
            $table->dropColumn(['short_desc','tags','location','address_line1','address_line2','city','zip','country']);
        });
    }
};