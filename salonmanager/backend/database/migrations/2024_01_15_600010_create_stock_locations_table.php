<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('stock_locations', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
      $t->string('name'); // Storefront, Backroom, Warehouse
      $t->boolean('is_default')->default(false);
      $t->json('meta')->nullable();
      $t->timestamps();
      $t->unique(['salon_id','name']);
    });
  }
  public function down(): void { Schema::dropIfExists('stock_locations'); }
};