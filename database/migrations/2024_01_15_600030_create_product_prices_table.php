<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('product_prices', function (Blueprint $t) {
      $t->id();
      $t->foreignId('product_id')->constrained('products')->cascadeOnDelete();
      $t->decimal('net_price',10,2);   // Verkauf Netto
      $t->decimal('tax_rate',5,2);     // redundanz, snapshot
      $t->decimal('gross_price',10,2); // convenience
      $t->boolean('active')->default(true);
      $t->timestamps();
    });
  }
  public function down(): void { Schema::dropIfExists('product_prices'); }
};