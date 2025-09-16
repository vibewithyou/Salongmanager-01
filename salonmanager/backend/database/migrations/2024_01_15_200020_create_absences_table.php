<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('absences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('stylist_id')->constrained('stylists')->cascadeOnDelete();
            $table->date('from_date');
            $table->date('to_date');
            $table->string('type'); // vacation, sick, other
            $table->string('status')->default('requested'); // requested, approved, rejected
            $table->text('note')->nullable();
            $table->timestamps();
            $table->index(['stylist_id', 'from_date', 'to_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('absences');
    }
};