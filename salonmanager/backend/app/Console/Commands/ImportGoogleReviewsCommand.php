<?php

namespace App\Console\Commands;

use App\Jobs\ImportGoogleReviewsJob;
use App\Models\Salon;
use Illuminate\Console\Command;

class ImportGoogleReviewsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'reviews:import-google 
                            {--salon= : Specific salon ID to import reviews for}
                            {--all : Import reviews for all salons with Google Place ID}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Import Google reviews for salons';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        if (!config('services.google.places_api_key')) {
            $this->error('Google Places API key not configured. Set GOOGLE_PLACES_API_KEY in .env');
            return Command::FAILURE;
        }

        if ($this->option('salon')) {
            // Import for specific salon
            $salon = Salon::find($this->option('salon'));
            
            if (!$salon) {
                $this->error('Salon not found');
                return Command::FAILURE;
            }

            if (!$salon->google_place_id) {
                $this->error('Salon does not have a Google Place ID configured');
                return Command::FAILURE;
            }

            $this->info("Importing Google reviews for salon: {$salon->name}");
            ImportGoogleReviewsJob::dispatch($salon, $salon->google_place_id);
            
        } elseif ($this->option('all')) {
            // Import for all salons with Google Place ID
            $salons = Salon::whereNotNull('google_place_id')->get();
            
            if ($salons->isEmpty()) {
                $this->warn('No salons found with Google Place ID');
                return Command::SUCCESS;
            }

            $this->info("Found {$salons->count()} salons with Google Place ID");
            
            foreach ($salons as $salon) {
                $this->info("Queueing import for: {$salon->name}");
                ImportGoogleReviewsJob::dispatch($salon, $salon->google_place_id);
            }
            
        } else {
            $this->error('Please specify --salon=ID or --all');
            return Command::FAILURE;
        }

        $this->info('Import job(s) queued successfully');
        return Command::SUCCESS;
    }
}