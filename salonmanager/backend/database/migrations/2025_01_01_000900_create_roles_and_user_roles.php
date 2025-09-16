<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('roles', function (Blueprint $t) {
      $t->id();
      $t->string('name')->unique(); // owner, platform_admin, salon_owner, salon_manager, stylist, customer
      $t->string('scope')->default('salon'); // 'global'|'salon'
      $t->timestamps();
    });

    Schema::create('user_roles', function (Blueprint $t) {
      $t->id();
      $t->foreignId('user_id')->constrained()->cascadeOnDelete();
      $t->foreignId('role_id')->constrained()->cascadeOnDelete();
      $t->foreignId('salon_id')->nullable()->constrained('salons')->nullOnDelete(); // null => global role
      $t->timestamps();
      $t->unique(['user_id','role_id','salon_id']); // ein Role nur einmal pro salon (oder global)
      $t->index(['salon_id','role_id']);
    });
  }
  public function down(): void {
    Schema::dropIfExists('user_roles');
    Schema::dropIfExists('roles');
  }
};