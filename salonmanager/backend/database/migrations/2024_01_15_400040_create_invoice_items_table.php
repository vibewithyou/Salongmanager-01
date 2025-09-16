<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('invoice_items', function (Blueprint $t) {
            $t->id();
            $t->foreignId('invoice_id')->constrained('invoices')->cascadeOnDelete();
            $t->string('type'); // service|product|custom
            $t->unsignedBigInteger('reference_id')->nullable(); // service_id/product_id
            $t->string('name');
            $t->integer('qty')->default(1);
            $t->decimal('unit_net', 10, 2);
            $t->decimal('tax_rate', 5, 2); // snapshot
            $t->decimal('line_net', 10, 2);
            $t->decimal('line_tax', 10, 2);
            $t->decimal('line_gross', 10, 2);
            $t->json('meta')->nullable(); // discount applied etc.
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('invoice_items');
    }
};