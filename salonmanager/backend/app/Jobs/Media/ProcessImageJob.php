<?php

namespace App\Jobs\Media;

use App\Models\MediaFile;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\ImageManager;

class ProcessImageJob implements ShouldQueue
{
    use Queueable;

    public function __construct(public int $fileId)
    {
    }

    public function handle(): void
    {
        $file = MediaFile::find($this->fileId);
        if (!$file) return;
        $disk = Storage::disk($file->disk);

        // download original
        $tmp = tempnam(sys_get_temp_dir(), 'img_');
        file_put_contents($tmp, $disk->get($file->path));

        $im = ImageManager::gd()->read($tmp);
        $w = $im->width();
        $h = $im->height();

        // create thumb 480px (longest)
        $thumb = clone $im;
        $thumb->scaleDown(width: 480, height: 480);
        $thumbKey = preg_replace('/(\.\w+)$/', '_thumb$1', $file->path);
        $disk->put($thumbKey, (string) $thumb->toJpeg(82), ['visibility' => 'private']);

        // optional webp
        $webpKey = preg_replace('/(\.\w+)$/', '.webp', $file->path);
        $disk->put($webpKey, (string) $im->toWebp(80), ['visibility' => 'private']);

        $file->width = $w;
        $file->height = $h;
        $file->variants = ['thumb' => $thumbKey, 'webp' => $webpKey];
        $file->save();

        // cleanup
        unlink($tmp);
    }
}