<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('loyalty_cards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->integer('points')->default(0);
            $table->json('meta')->nullable(); // tier, expires_at, etc.
            $table->timestamps();
            $table->unique(['salon_id', 'customer_id']);
        });

        Schema::create('loyalty_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->foreignId('card_id')->constrained('loyalty_cards')->cascadeOnDelete();
            $table->integer('delta'); // + / - points
            $table->string('reason')->nullable(); // booking, refund, promo
            $table->json('meta')->nullable();
            $table->timestamps();
            $table->index(['card_id', 'created_at']);
        });

        Schema::create('discounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('salon_id')->constrained('salons')->cascadeOnDelete();
            $table->string('code')->unique();
            $table->string('type'); // percent|fixed
            $table->decimal('value', 8, 2);
            $table->date('valid_from')->nullable();
            $table->date('valid_to')->nullable();
            $table->boolean('active')->default(true);
            $table->json('conditions')->nullable(); // min_amount, service_ids, customer_tier...
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('discounts');
        Schema::dropIfExists('loyalty_transactions');
        Schema::dropIfExists('loyalty_cards');
    }
};