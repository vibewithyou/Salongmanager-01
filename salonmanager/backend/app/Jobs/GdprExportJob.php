<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use ZipArchive;
use App\Models\User;

class GdprExportJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        private int $userId,
        private string $exportId
    ) {}

    public function handle(): void
    {
        try {
            $user = User::with([
                'profile',
                'bookings' => function ($query) {
                    $query->with(['services', 'staff']);
                },
                'loyaltyTransactions',
                'media'
            ])->find($this->userId);

            if (!$user) {
                Log::error('GDPR Export: User not found', ['user_id' => $this->userId]);
                return;
            }

            $exportData = $this->collectUserData($user);
            $zipPath = $this->createZipFile($exportData, $this->exportId);
            
            Log::info('GDPR Export completed', [
                'user_id' => $this->userId,
                'export_id' => $this->exportId,
                'zip_path' => $zipPath
            ]);

        } catch (\Exception $e) {
            Log::error('GDPR Export failed', [
                'user_id' => $this->userId,
                'export_id' => $this->exportId,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            throw $e;
        }
    }

    private function collectUserData(User $user): array
    {
        return [
            'user_profile' => [
                'id' => $user->id,
                'email' => $user->email,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
                'profile' => $user->profile ? [
                    'first_name' => $user->profile->first_name,
                    'last_name' => $user->profile->last_name,
                    'phone' => $user->profile->phone,
                    'date_of_birth' => $user->profile->date_of_birth,
                    'address' => $user->profile->address,
                    'city' => $user->profile->city,
                    'postal_code' => $user->profile->postal_code,
                    'country' => $user->profile->country,
                    'created_at' => $user->profile->created_at,
                    'updated_at' => $user->profile->updated_at,
                ] : null,
            ],
            'bookings' => $user->bookings?->map(function ($booking) {
                return [
                    'id' => $booking->id,
                    'date' => $booking->date,
                    'time' => $booking->time,
                    'status' => $booking->status,
                    'total' => $booking->total,
                    'notes' => $booking->notes,
                    'services' => $booking->services?->map(function ($service) {
                        return [
                            'name' => $service->name,
                            'price' => $service->price,
                            'duration' => $service->duration,
                        ];
                    }),
                    'staff' => $booking->staff ? [
                        'name' => $booking->staff->name,
                        'email' => $booking->staff->email,
                    ] : null,
                    'created_at' => $booking->created_at,
                    'updated_at' => $booking->updated_at,
                ];
            }) ?? [],
            'loyalty_transactions' => $user->loyaltyTransactions?->map(function ($transaction) {
                return [
                    'id' => $transaction->id,
                    'type' => $transaction->type,
                    'points' => $transaction->points,
                    'description' => $transaction->description,
                    'created_at' => $transaction->created_at,
                ];
            }) ?? [],
            'media' => $user->media?->map(function ($media) {
                return [
                    'id' => $media->id,
                    'type' => $media->type,
                    'file_name' => $media->file_name,
                    'file_path' => $media->file_path,
                    'created_at' => $media->created_at,
                ];
            }) ?? [],
        ];
    }

    private function createZipFile(array $data, string $exportId): string
    {
        $zipPath = "exports/{$exportId}.zip";
        $tempDir = storage_path("app/temp/exports/{$exportId}");
        
        // Create temp directory
        if (!is_dir($tempDir)) {
            mkdir($tempDir, 0755, true);
        }

        // Create JSON files
        file_put_contents(
            "{$tempDir}/user_data.json",
            json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)
        );

        // Create README
        $readme = "GDPR Data Export\n";
        $readme .= "Generated: " . now()->toISOString() . "\n";
        $readme .= "User ID: {$this->userId}\n";
        $readme .= "Export ID: {$exportId}\n\n";
        $readme .= "This export contains all personal data associated with your account.\n";
        $readme .= "Files included:\n";
        $readme .= "- user_data.json: Complete user profile and associated data\n";
        $readme .= "- README.txt: This file\n\n";
        $readme .= "Data retention: This export will be automatically deleted after 30 days.\n";
        
        file_put_contents("{$tempDir}/README.txt", $readme);

        // Create ZIP file
        $zip = new ZipArchive();
        $zipPath = storage_path("app/{$zipPath}");
        
        if ($zip->open($zipPath, ZipArchive::CREATE) !== TRUE) {
            throw new \Exception("Cannot create ZIP file: {$zipPath}");
        }

        $zip->addFile("{$tempDir}/user_data.json", "user_data.json");
        $zip->addFile("{$tempDir}/README.txt", "README.txt");
        $zip->close();

        // Clean up temp directory
        $this->deleteDirectory($tempDir);

        return $zipPath;
    }

    private function deleteDirectory(string $dir): void
    {
        if (!is_dir($dir)) {
            return;
        }

        $files = array_diff(scandir($dir), ['.', '..']);
        foreach ($files as $file) {
            $path = "{$dir}/{$file}";
            is_dir($path) ? $this->deleteDirectory($path) : unlink($path);
        }
        rmdir($dir);
    }
}
