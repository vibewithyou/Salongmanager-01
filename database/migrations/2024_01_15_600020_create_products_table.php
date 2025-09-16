<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('products', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
      $t->foreignId('supplier_id')->nullable()->constrained('suppliers')->nullOnDelete();
      $t->string('sku')->unique();
      $t->string('barcode')->nullable()->unique();
      $t->string('name');
      $t->text('description')->nullable();
      $t->decimal('tax_rate',5,2)->default(19.00); // snapshot standard
      $t->integer('reorder_point')->default(0);    // Mindestbestand
      $t->integer('reorder_qty')->default(0);      // Vorschlagsmenge
      $t->json('meta')->nullable(); // brand, size(ml), etc.
      $t->timestamps();
      $t->index(['salon_id','name']);
    });
  }
  public function down(): void { Schema::dropIfExists('products'); }
};