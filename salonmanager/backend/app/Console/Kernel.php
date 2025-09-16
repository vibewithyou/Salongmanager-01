<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // Media retention cleanup - run daily at 3:30 AM
        $schedule->command('media:purge-expired')->dailyAt('03:30');
        
        // Import Google reviews - run daily at 2:00 AM
        $schedule->command('reviews:import-google --all')
            ->dailyAt('02:00')
            ->withoutOverlapping()
            ->onFailure(function () {
                \Log::error('Failed to import Google reviews');
            });
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}