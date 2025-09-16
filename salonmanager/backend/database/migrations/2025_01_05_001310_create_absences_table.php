<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('absences', function (Blueprint $t) {
            $t->id();
            $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $t->foreignId('user_id')->constrained('users')->cascadeOnDelete(); // stylist
            $t->foreignId('stylist_id')->nullable()->constrained('stylists')->nullOnDelete();
            $t->dateTime('start_at');
            $t->dateTime('end_at');
            $t->date('from_date')->nullable();
            $t->date('to_date')->nullable();
            $t->string('type')->default('vacation'); // vacation|sick|other
            $t->string('status')->default('pending'); // pending|approved|rejected
            $t->text('reason')->nullable();
            $t->text('note')->nullable();
            $t->timestamps();

            $t->index(['salon_id', 'user_id', 'start_at', 'status']);
            $t->index(['salon_id', 'stylist_id', 'start_at', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('absences');
    }
};
