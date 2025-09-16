<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $t) {
            $t->id();
            $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $t->foreignId('invoice_id')->constrained('invoices')->cascadeOnDelete();
            $t->string('method'); // cash|card|external
            $t->decimal('amount', 10, 2);
            $t->json('meta')->nullable(); // external provider id, last4, etc.
            $t->timestamp('paid_at');
            $t->timestamps();
        });

        Schema::create('refunds', function (Blueprint $t) {
            $t->id();
            $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $t->foreignId('invoice_id')->constrained('invoices')->cascadeOnDelete();
            $t->decimal('amount', 10, 2);
            $t->string('reason')->nullable();
            $t->json('lines')->nullable(); // partial refund: [{item_id, qty, amount}]
            $t->timestamp('refunded_at');
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('refunds');
        Schema::dropIfExists('payments');
    }
};