<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('salons', function (Blueprint $table) {
            $table->string('logo_path')->nullable();
            $table->json('brand')->nullable();               // e.g. fonts, corner radius, darkMode default
            $table->json('seo')->nullable();                 // title, description, keywords
            $table->json('social')->nullable();              // links: instagram, tiktok, web
            $table->json('content_settings')->nullable();    // feature toggles, layout prefs
        });
    }
    
    public function down(): void {
        Schema::table('salons', function (Blueprint $table) {
            $table->dropColumn(['logo_path', 'brand', 'seo', 'social', 'content_settings']);
        });
    }
};