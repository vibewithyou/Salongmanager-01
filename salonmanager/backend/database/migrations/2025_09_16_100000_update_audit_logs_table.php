<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('audit_logs', function (Blueprint $table) {
            // Add missing columns
            $table->string('entity_type')->nullable()->after('action');
            $table->unsignedBigInteger('entity_id')->nullable()->after('entity_type');
            $table->string('method', 10)->nullable()->after('user_agent');
            $table->string('path', 255)->nullable()->after('method');
            
            // Update user_agent column size
            $table->string('user_agent', 255)->nullable()->change();
            
            // Rename user_agent to ua for consistency
            $table->renameColumn('user_agent', 'ua');
            
            // Add missing updated_at timestamp
            $table->timestamp('updated_at')->nullable();
            
            // Add indices
            $table->index(['salon_id', 'action']);
            $table->index(['entity_type', 'entity_id']);
            $table->index(['created_at']);
        });
    }
    
    public function down(): void {
        Schema::table('audit_logs', function (Blueprint $table) {
            $table->dropIndex(['salon_id', 'action']);
            $table->dropIndex(['entity_type', 'entity_id']);
            $table->dropIndex(['created_at']);
            
            $table->dropColumn(['entity_type', 'entity_id', 'method', 'path', 'updated_at']);
            $table->renameColumn('ua', 'user_agent');
            $table->text('user_agent')->nullable()->change();
        });
    }
};