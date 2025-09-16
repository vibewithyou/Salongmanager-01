<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    Schema::create('invoice_sequences', function (Blueprint $t) {
      $t->id();
      $t->unsignedBigInteger('salon_id');
      $t->unsignedSmallInteger('year');
      $t->unsignedBigInteger('current_no')->default(0);
      $t->timestamps();
      $t->unique(['salon_id','year']);
    });
    
    // Add invoice number fields if they don't exist
    if (!Schema::hasColumn('invoices','number')) {
      Schema::table('invoices', function (Blueprint $t) {
        $t->string('number')->unique()->nullable();
        $t->timestamp('paid_at')->nullable();
        $t->timestamp('refunded_at')->nullable();
      });
    }
  }
  public function down(): void {
    Schema::dropIfExists('invoice_sequences');
    if (Schema::hasColumn('invoices', 'number')) {
      Schema::table('invoices', fn(Blueprint $t)=>$t->dropColumn(['number','paid_at','refunded_at']));
    }
  }
};
