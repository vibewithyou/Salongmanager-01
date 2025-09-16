<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('purchase_orders', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
      $t->foreignId('supplier_id')->constrained('suppliers')->cascadeOnDelete();
      $t->string('number')->unique(); // PO-YYYY-000001
      $t->string('status')->default('draft'); // draft|ordered|received|canceled
      $t->json('meta')->nullable(); // notes, terms
      $t->timestamps();
    });

    Schema::create('purchase_order_items', function (Blueprint $t) {
      $t->id();
      $t->foreignId('po_id')->constrained('purchase_orders')->cascadeOnDelete();
      $t->foreignId('product_id')->constrained('products')->cascadeOnDelete();
      $t->integer('qty')->default(1);
      $t->decimal('unit_cost',10,2)->default(0); // optional
      $t->timestamps();
    });
  }
  public function down(): void {
    Schema::dropIfExists('purchase_order_items');
    Schema::dropIfExists('purchase_orders');
  }
};