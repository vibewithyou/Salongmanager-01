<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invoice_sequences', function (Blueprint $t) {
            $t->id();
            $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $t->integer('year');
            $t->unsignedBigInteger('current_no')->default(0);
            $t->timestamps();
            $t->unique(['salon_id', 'year']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invoice_sequences');
    }
};