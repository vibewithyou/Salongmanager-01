<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('work_rules', function (Blueprint $t) {
            $t->id();
            $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $t->unsignedSmallInteger('max_hours_per_day')->default(10);
            $t->unsignedSmallInteger('min_break_minutes_per6h')->default(30);
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('work_rules');
    }
};