<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('consents', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('salon_id')->nullable();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('type')->default('cookie_basic');
            $table->boolean('accepted')->default(true);
            $table->string('ua')->nullable();
            $table->timestamps();
            $table->index(['salon_id','type','created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('consents');
    }
};
