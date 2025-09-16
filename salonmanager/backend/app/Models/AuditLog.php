<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Support\Tenancy\SalonOwned;

class AuditLog extends Model
{
    use SalonOwned;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'salon_id',
        'user_id',
        'action',
        'entity_type',
        'entity_id',
        'meta',
        'ip',
        'ua',
        'method',
        'path'
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'meta' => 'array',
        ];
    }

    /**
     * Get the user that performed the action.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the salon related to the log.
     */
    public function salon()
    {
        return $this->belongsTo(Salon::class);
    }
}