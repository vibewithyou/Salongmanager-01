<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
  public function up(): void {
    $ix = function($t, $cols) {
      Schema::table($t, function(Blueprint $b) use($cols){ 
        foreach ($cols as $c) {
          if (!Schema::hasIndex($t, [$c])) {
            $b->index($c); 
          }
        }
      });
    };
    
    // Bookings indexes
    $ix('bookings', ['salon_id','stylist_id','customer_id','status','start_at']);
    
    // Invoices indexes
    $ix('invoices', ['salon_id','status','created_at']);
    
    // Absences indexes
    if (Schema::hasTable('absences')) {
      $ix('absences', ['salon_id','user_id','status','start_at']);
    }
    
    // Shifts indexes
    if (Schema::hasTable('shifts')) {
      $ix('shifts', ['salon_id','user_id','start_at']);
    }
    
    // Reviews indexes
    if (Schema::hasTable('reviews')) {
      $ix('reviews', ['salon_id','rating','created_at']);
    }
    
    // Inventory items indexes
    if (Schema::hasTable('stock_items')) {
      $ix('stock_items', ['salon_id','product_id','location_id']);
    }
    
    // Loyalty transactions indexes
    if (Schema::hasTable('loyalty_transactions')) {
      $ix('loyalty_transactions', ['salon_id','customer_id','created_at']);
    }
    
    // Webhook events indexes
    if (Schema::hasTable('webhook_events')) {
      $ix('webhook_events', ['provider','event_type','created_at']);
    }
    
    // Idempotency keys indexes
    if (Schema::hasTable('idempotency_keys')) {
      $ix('idempotency_keys', ['scope','created_at']);
    }
  }
  
  public function down(): void {
    // Optional: drop indexes if needed
    // For now, we'll leave them as they improve performance
  }
};
