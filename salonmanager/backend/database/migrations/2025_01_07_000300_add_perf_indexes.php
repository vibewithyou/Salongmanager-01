<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add performance indexes for hot paths
        $this->addIndexes('bookings', ['salon_id', 'stylist_id', 'customer_id', 'status', 'start_at']);
        $this->addIndexes('invoices', ['salon_id', 'status', 'created_at']);
        $this->addIndexes('absences', ['salon_id', 'user_id', 'status', 'start_at']);
        $this->addIndexes('shifts', ['salon_id', 'user_id', 'start_at']);
        $this->addIndexes('reviews', ['salon_id', 'rating', 'created_at']);
    }

    private function addIndexes(string $table, array $columns): void
    {
        if (Schema::hasTable($table)) {
            Schema::table($table, function (Blueprint $table) use ($columns) {
                foreach ($columns as $column) {
                    if (!$this->indexExists($table, $column)) {
                        $table->index($column);
                    }
                }
            });
        }
    }

    private function indexExists(string $table, string $column): bool
    {
        $indexes = Schema::getConnection()
            ->getDoctrineSchemaManager()
            ->listTableIndexes($table);
        
        return array_key_exists($table . '_' . $column . '_index', $indexes);
    }

    public function down(): void
    {
        // Indexes will be dropped when tables are dropped
    }
};
