<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('suppliers', function (Blueprint $t) {
      $t->id();
      $t->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
      $t->string('name');
      $t->string('email')->nullable();
      $t->string('phone')->nullable();
      $t->json('address')->nullable();
      $t->json('meta')->nullable(); // payment terms, vendor code
      $t->timestamps();
      $t->unique(['salon_id','name']);
    });
  }
  public function down(): void { Schema::dropIfExists('suppliers'); }
};