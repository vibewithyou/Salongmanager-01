<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\MediaFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Carbon;

class MediaPurgeExpired extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'media:purge-expired';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Delete expired media (retention_until or revoked consent)';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $query = MediaFile::query()
            ->where(function ($where) {
                $where->whereNotNull('retention_until')
                    ->where('retention_until', '<=', Carbon::today())
                    ->orWhere('consent_status', 'revoked');
            });

        $disk = Storage::disk('media');
        $deletedCount = 0;

        $query->chunkById(200, function ($files) use ($disk, &$deletedCount) {
            foreach ($files as $file) {
                // Delete all variants
                $pathsToDelete = [$file->path];
                if ($file->variants) {
                    $pathsToDelete = array_merge($pathsToDelete, array_values($file->variants));
                }

                $disk->delete($pathsToDelete);
                $file->forceDelete();
                $deletedCount++;
            }
        });

        $this->info("Expired media purged: {$deletedCount} files deleted.");
        return self::SUCCESS;
    }
}