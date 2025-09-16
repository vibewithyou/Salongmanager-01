<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class RepoScanOrphans extends Command
{
    protected $signature = 'repo:scan-orphans';
    protected $description = 'Detect PHP files that look like Laravel app code but live outside salonmanager/backend';

    public function handle(): int
    {
        $root = base_path('..'); // monorepo root = parent of backend
        $backend = base_path();  // salonmanager/backend
        $errors = [];

        // scan candidates outside backend that look like app or database code
        $patterns = [
            $root . '/app/*.php',
            $root . '/app/*/*.php',
            $root . '/database/migrations/*.php',
            $root . '/backend/app/*.php',        // stray second backend
            $root . '/backend/database/migrations/*.php',
        ];

        foreach ($patterns as $gl) {
            foreach (glob($gl) as $file) {
                $errors[] = $file;
            }
        }

        if (!empty($errors)) {
            $this->error("Found orphaned PHP files outside salonmanager/backend:");
            foreach ($errors as $f) $this->line(" - $f");
            $this->line("Please move them under salonmanager/backend and fix namespaces.");
            return self::FAILURE;
        }

        $this->info('No orphans detected. Clean repository.');
        return self::SUCCESS;
    }
}