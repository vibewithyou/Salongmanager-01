<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use App\Support\Tenancy\SalonOwned;

class MediaFile extends Model
{
    use SoftDeletes, SalonOwned;

    protected $fillable = [
        'salon_id', 'owner_type', 'owner_id', 'disk', 'path', 'mime', 'bytes', 'width', 'height',
        'variants', 'derivatives', 'exif', 'consent_required', 'consent_status', 'subject_user_id', 'subject_name',
        'subject_contact', 'retention_until', 'visibility'
    ];

    protected $casts = [
        'variants' => 'array',
        'derivatives' => 'array',
        'exif' => 'array',
        'consent_required' => 'boolean',
        'retention_until' => 'date'
    ];

    public function url(?string $variant = null): string
    {
        $disk = \Storage::disk($this->disk);
        $path = $variant && isset($this->variants[$variant]) ? $this->variants[$variant] : $this->path;
        $base = config('filesystems.disks.' . $this->disk . '.url');
        return $base ? rtrim($base, '/') . '/' . ltrim($path, '/') : $disk->url($path);
    }

    /**
     * Get URL for a specific derivative size
     */
    public function derivativeUrl(string $size = 'web'): string
    {
        if (!$this->derivatives || !isset($this->derivatives[$size])) {
            return $this->url();
        }

        $disk = \Storage::disk($this->disk);
        $path = $this->derivatives[$size]['path'];
        $base = config('filesystems.disks.' . $this->disk . '.url');
        return $base ? rtrim($base, '/') . '/' . ltrim($path, '/') : $disk->url($path);
    }

    /**
     * Get derivative dimensions
     */
    public function derivativeDimensions(string $size = 'web'): ?array
    {
        if (!$this->derivatives || !isset($this->derivatives[$size])) {
            return null;
        }

        return [
            'width' => $this->derivatives[$size]['width'],
            'height' => $this->derivatives[$size]['height'],
        ];
    }

    public function owner()
    {
        return $this->morphTo();
    }

    public function subjectUser()
    {
        return $this->belongsTo(User::class, 'subject_user_id');
    }

    public function salon()
    {
        return $this->belongsTo(Salon::class);
    }
}