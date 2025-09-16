<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tax_rates', function (Blueprint $t) {
            $t->id();
            $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $t->string('name'); // e.g., "DE 19%"
            $t->decimal('rate', 5, 2); // e.g., 19.00
            $t->boolean('active')->default(true);
            $t->timestamps();
            $t->unique(['salon_id', 'name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tax_rates');
    }
};