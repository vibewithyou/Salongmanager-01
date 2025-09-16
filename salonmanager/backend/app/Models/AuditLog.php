<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;

class AuditLog extends Model
{
    protected $fillable = [
        'actor_id',
        'actor_type',
        'action',
        'entity_type',
        'entity_id',
        'meta',
        'method',
        'path',
        'ip',
        'user_agent',
    ];

    protected $casts = [
        'meta' => 'array',
    ];

    public function actor(): MorphTo
    {
        return $this->morphTo();
    }

    public function entity(): MorphTo
    {
        return $this->morphTo();
    }

    /**
     * Create an audit log entry
     */
    public static function log(
        string $action,
        $entity = null,
        $actor = null,
        array $meta = [],
        ?string $method = null,
        ?string $path = null,
        ?string $ip = null,
        ?string $userAgent = null
    ): self {
        return self::create([
            'actor_id' => $actor?->id,
            'actor_type' => $actor ? get_class($actor) : null,
            'action' => $action,
            'entity_type' => $entity ? get_class($entity) : null,
            'entity_id' => $entity?->id,
            'meta' => $meta,
            'method' => $method,
            'path' => $path,
            'ip' => $ip,
            'user_agent' => $userAgent,
        ]);
    }
}