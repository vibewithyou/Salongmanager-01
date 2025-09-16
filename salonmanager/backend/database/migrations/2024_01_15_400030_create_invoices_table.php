<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invoices', function (Blueprint $t) {
            $t->id();
            $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $t->foreignId('pos_session_id')->nullable()->constrained('pos_sessions')->nullOnDelete();
            $t->foreignId('customer_id')->nullable()->constrained('users')->nullOnDelete();
            $t->string('number')->unique(); // GoBD: immutable once set
            $t->timestamp('issued_at');
            $t->decimal('total_net', 10, 2);
            $t->decimal('total_tax', 10, 2);
            $t->decimal('total_gross', 10, 2);
            $t->json('tax_breakdown'); // [{rate:19, net:.., tax:..}, ...]
            $t->string('status')->default('open'); // open, paid, refunded, canceled
            $t->json('meta')->nullable(); // discounts, notes
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invoices');
    }
};