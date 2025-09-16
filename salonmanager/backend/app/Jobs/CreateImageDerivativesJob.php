<?php

namespace App\Jobs;

use App\Models\MediaFile;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class CreateImageDerivativesJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(
        public MediaFile $mediaFile
    ) {}

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        if (!$this->isImageFile()) {
            return;
        }

        try {
            $manager = new ImageManager(new Driver());
            $image = $manager->read(Storage::disk($this->mediaFile->disk)->get($this->mediaFile->path));

            // Get original dimensions
            $originalWidth = $image->width();
            $originalHeight = $image->height();

            // Create thumbnail (150x150, maintain aspect ratio)
            $thumbnail = clone $image;
            $thumbnail->scaleDown(150, 150);
            $thumbnailPath = $this->getDerivativePath('thumb');
            Storage::disk($this->mediaFile->disk)->put($thumbnailPath, $thumbnail->toJpeg(85));

            // Create medium size (400x400, maintain aspect ratio)
            $medium = clone $image;
            $medium->scaleDown(400, 400);
            $mediumPath = $this->getDerivativePath('medium');
            Storage::disk($this->mediaFile->disk)->put($mediumPath, $medium->toJpeg(90));

            // Create web-optimized version (max 800px width)
            $web = clone $image;
            if ($web->width() > 800) {
                $web->scaleDown(800, 800);
            }
            $webPath = $this->getDerivativePath('web');
            Storage::disk($this->mediaFile->disk)->put($webPath, $web->toWebp(90));

            // Update media file with derivative info
            $this->mediaFile->update([
                'derivatives' => [
                    'original' => [
                        'path' => $this->mediaFile->path,
                        'width' => $originalWidth,
                        'height' => $originalHeight,
                        'size' => Storage::disk($this->mediaFile->disk)->size($this->mediaFile->path),
                    ],
                    'thumbnail' => [
                        'path' => $thumbnailPath,
                        'width' => $thumbnail->width(),
                        'height' => $thumbnail->height(),
                        'size' => Storage::disk($this->mediaFile->disk)->size($thumbnailPath),
                    ],
                    'medium' => [
                        'path' => $mediumPath,
                        'width' => $medium->width(),
                        'height' => $medium->height(),
                        'size' => Storage::disk($this->mediaFile->disk)->size($mediumPath),
                    ],
                    'web' => [
                        'path' => $webPath,
                        'width' => $web->width(),
                        'height' => $web->height(),
                        'size' => Storage::disk($this->mediaFile->disk)->size($webPath),
                    ],
                ],
            ]);

        } catch (\Exception $e) {
            \Log::error('Failed to create image derivatives', [
                'media_file_id' => $this->mediaFile->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Check if the media file is an image
     */
    private function isImageFile(): bool
    {
        $mimeType = $this->mediaFile->mime;
        return str_starts_with($mimeType, 'image/');
    }

    /**
     * Generate derivative path
     */
    private function getDerivativePath(string $size): string
    {
        $pathInfo = pathinfo($this->mediaFile->path);
        return $pathInfo['dirname'] . '/' . $pathInfo['filename'] . '_' . $size . '.webp';
    }
}
