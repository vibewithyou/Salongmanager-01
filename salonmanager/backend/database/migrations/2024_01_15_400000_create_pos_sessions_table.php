<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pos_sessions', function (Blueprint $t) {
            $t->id();
            $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $t->foreignId('user_id')->constrained('users')->cascadeOnDelete(); // opened by
            $t->timestamp('opened_at');
            $t->timestamp('closed_at')->nullable();
            $t->decimal('opening_cash', 10, 2)->default(0);
            $t->decimal('closing_cash', 10, 2)->nullable();
            $t->json('meta')->nullable(); // register id, note, etc.
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pos_sessions');
    }
};