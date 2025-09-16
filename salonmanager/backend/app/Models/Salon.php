<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Support\Facades\DB;

class Salon extends Model
{
    use HasFactory;
    protected $fillable = [
        'name', 'slug', 'primary_color', 'secondary_color', 'logo_path', 'brand', 'seo', 'social', 'content_settings',
        'short_desc', 'tags', 'location', 'address_line1', 'address_line2', 'city', 'zip', 'country'
    ];

    protected $casts = [
        'brand' => 'array',
        'seo' => 'array',
        'social' => 'array',
        'content_settings' => 'array',
        'tags' => 'array',
    ];

    public function openingHours() { 
        return $this->hasMany(OpeningHour::class); 
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    /**
     * Get the average rating for the salon.
     */
    public function avgRating(): ?float
    {
        $avg = $this->reviews()
            ->where('approved', true)
            ->avg('rating');
        
        return $avg ? round($avg, 1) : null;
    }

    /**
     * Get the total number of approved reviews.
     */
    public function reviewCount(): int
    {
        return $this->reviews()
            ->where('approved', true)
            ->count();
    }

    /**
     * Get rating statistics for the salon.
     */
    public function ratingStats(): array
    {
        return [
            'average' => $this->avgRating(),
            'count' => $this->reviewCount(),
            'distribution' => $this->getRatingDistribution()
        ];
    }

    /**
     * Get rating distribution (count per rating value).
     */
    protected function getRatingDistribution(): array
    {
        $distribution = $this->reviews()
            ->where('approved', true)
            ->selectRaw('rating, COUNT(*) as count')
            ->groupBy('rating')
            ->pluck('count', 'rating')
            ->toArray();

        // Ensure all ratings 1-5 are present
        $result = [];
        for ($i = 1; $i <= 5; $i++) {
            $result[$i] = $distribution[$i] ?? 0;
        }

        return $result;
    }

    public function scopePublicFields($q) {
        return $q->select([
            'id','name','slug','logo_path','short_desc',
            'primary_color','secondary_color',
            'address_line1','address_line2','city','zip','country',
            DB::raw('ST_X(location) as lat'),
            DB::raw('ST_Y(location) as lng'),
        ])
        ->addSelect([
            'avg_rating' => Review::selectRaw('ROUND(AVG(rating), 1)')
                ->whereColumn('salon_id', 'salons.id')
                ->where('approved', true),
            'review_count' => Review::selectRaw('COUNT(*)')
                ->whereColumn('salon_id', 'salons.id')
                ->where('approved', true)
        ]);
    }
}