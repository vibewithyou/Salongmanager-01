<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('stock_items', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
      $t->foreignId('product_id')->constrained('products')->cascadeOnDelete();
      $t->foreignId('location_id')->constrained('stock_locations')->cascadeOnDelete();
      $t->integer('qty')->default(0);
      $t->timestamps();
      $t->unique(['product_id','location_id']); // per location Bestand
    });

    Schema::create('stock_movements', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
      $t->foreignId('product_id')->constrained('products')->cascadeOnDelete();
      $t->foreignId('location_id')->constrained('stock_locations')->cascadeOnDelete();
      $t->string('type'); // in|out|transfer|sale|correction|po_receive
      $t->integer('delta'); // +/-
      $t->json('meta')->nullable(); // ref: invoice_id, po_id, note
      $t->timestamp('moved_at');
      $t->timestamps();
      $t->index(['product_id','moved_at']);
    });
  }
  public function down(): void {
    Schema::dropIfExists('stock_movements');
    Schema::dropIfExists('stock_items');
  }
};