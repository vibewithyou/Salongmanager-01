<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add salon_id to users table (but keep it nullable for system users)
        if (!Schema::hasColumn('users', 'salon_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to personal_access_tokens
        if (!Schema::hasColumn('personal_access_tokens', 'salon_id')) {
            Schema::table('personal_access_tokens', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to invoice_items
        if (!Schema::hasColumn('invoice_items', 'salon_id')) {
            Schema::table('invoice_items', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to product_prices
        if (!Schema::hasColumn('product_prices', 'salon_id')) {
            Schema::table('product_prices', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to invoices
        if (!Schema::hasColumn('invoices', 'salon_id')) {
            Schema::table('invoices', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to bookings
        if (!Schema::hasColumn('bookings', 'salon_id')) {
            Schema::table('bookings', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to roles (tenant-specific roles)
        if (!Schema::hasColumn('roles', 'salon_id')) {
            Schema::table('roles', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to permissions (tenant-specific permissions)
        if (!Schema::hasColumn('permissions', 'salon_id')) {
            Schema::table('permissions', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to booking_services
        if (!Schema::hasColumn('booking_services', 'salon_id')) {
            Schema::table('booking_services', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to booking_media
        if (!Schema::hasColumn('booking_media', 'salon_id')) {
            Schema::table('booking_media', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }

        // Add salon_id to gallery_photos
        if (!Schema::hasColumn('gallery_photos', 'salon_id')) {
            Schema::table('gallery_photos', function (Blueprint $table) {
                $table->foreignId('salon_id')->nullable()->after('id')->index();
                $table->foreign('salon_id')->references('id')->on('salons')->onDelete('cascade');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove foreign key constraints first
        $tables = [
            'users', 'personal_access_tokens', 'invoice_items', 'product_prices',
            'invoices', 'bookings', 'roles', 'permissions', 'booking_services',
            'booking_media', 'gallery_photos'
        ];

        foreach ($tables as $table) {
            if (Schema::hasColumn($table, 'salon_id')) {
                Schema::table($table, function (Blueprint $table) {
                    $table->dropForeign(['salon_id']);
                    $table->dropColumn('salon_id');
                });
            }
        }
    }
};
