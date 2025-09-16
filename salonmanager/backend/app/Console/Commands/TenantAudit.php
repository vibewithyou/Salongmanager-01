<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class TenantAudit extends Command
{
    protected $signature = 'audit:tenant {--fix-indexes} {--fix-missing}';
    protected $description = 'Check all tables for salon_id presence and indexes; optionally create auto migrations';

    public function handle(): int
    {
        $db = config('database.connections.'.config('database.default').'.database');
        $tables = collect(DB::select('SHOW TABLES'))->map(fn($r)=>array_values((array)$r)[0])
            ->filter(fn($t)=>!in_array($t, ['migrations','password_resets','failed_jobs','jobs','job_batches','personal_access_tokens']));

        $missingSalon = [];
        $missingIdx = [];
        foreach ($tables as $t) {
            $cols = collect(DB::select("SHOW COLUMNS FROM `$t`"))->pluck('Field')->all();
            if (!in_array('salon_id', $cols)) {
                $missingSalon[] = $t;
                continue;
            }
            $idx = collect(DB::select("SHOW INDEX FROM `$t`"))->pluck('Column_name')->all();
            if (!in_array('salon_id', $idx)) $missingIdx[] = $t;
        }

        @mkdir(base_path('../ops/audit'), 0777, true);
        file_put_contents(base_path('../ops/audit/tenant_missing_salon.txt'), implode("\n", $missingSalon));
        file_put_contents(base_path('../ops/audit/tenant_missing_index.txt'), implode("\n", $missingIdx));

        $this->info("Tables without salon_id: ".count($missingSalon));
        $this->info("Tables without index on salon_id: ".count($missingIdx));

        if ($this->option('fix-missing') && $missingSalon) {
            $this->createMigrationAddSalon($missingSalon);
        }
        if ($this->option('fix-indexes') && $missingIdx) {
            $this->createMigrationAddIndex($missingIdx);
        }
        return self::SUCCESS;
    }

    private function createMigrationAddSalon(array $tables): void
    {
        $ts = date('Y_m_d_His');
        $path = database_path("migrations/{$ts}_add_salon_id_missing_tables.php");
        $body = "<?php\nuse Illuminate\\Database\\Migrations\\Migration;\nuse Illuminate\\Database\\Schema\\Blueprint;\nuse Illuminate\\Support\\Facades\\Schema;\nreturn new class extends Migration{public function up():void{";
        foreach ($tables as $t) {
            $body .= "if(!Schema::hasColumn('{$t}','salon_id')){Schema::table('{$t}',function(Blueprint \$table){\$table->foreignId('salon_id')->nullable()->after('id')->index();});}";
        }
        $body .= "} public function down():void{";
        foreach ($tables as $t) {
            $body .= "if(Schema::hasColumn('{$t}','salon_id')){Schema::table('{$t}',function(Blueprint \$table){\$table->dropColumn('salon_id');});}";
        }
        $body .= "}};";
        file_put_contents($path, $body);
        $this->info("Created migration: $path");
    }

    private function createMigrationAddIndex(array $tables): void
    {
        $ts = date('Y_m_d_His', time()+1);
        $path = database_path("migrations/{$ts}_add_index_salon_id_missing.php");
        $body = "<?php\nuse Illuminate\\Database\\Migrations\\Migration;\nuse Illuminate\\Database\\Schema\\Blueprint;\nuse Illuminate\\Support\\Facades\\Schema;\nreturn new class extends Migration{public function up():void{";
        foreach ($tables as $t) {
            $body .= "Schema::table('{$t}',function(Blueprint \$table){\$table->index('salon_id');});";
        }
        $body .= "} public function down():void{";
        foreach ($tables as $t) {
            $body .= "Schema::table('{$t}',function(Blueprint \$table){\$table->dropIndex(['salon_id']);});";
        }
        $body .= "}};";
        file_put_contents($path, $body);
        $this->info("Created migration: $path");
    }
}
