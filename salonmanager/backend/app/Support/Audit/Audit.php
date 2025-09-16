<?php

namespace App\Support\Audit;

use App\Models\AuditLog;

class Audit
{
    /**
     * Schreibe einen Audit-Eintrag.
     * @param string $action       z.B. 'booking.confirmed'
     * @param string|null $type    Entity Classname/Label: 'Booking','Invoice','MediaFile','User',...
     * @param int|null $id         Entity ID
     * @param array $meta          nur nicht-sensitive Zusatzinformationen!
     */
    public static function write(string $action, ?string $type = null, ?int $id = null, array $meta = []): void
    {
        $req = request();
        $tenant = app()->bound('tenant') ? app('tenant') : null;
        $user = $req?->user();

        // PII vermeiden – meta whitelisten/klein halten!
        $meta = self::sanitizeMeta($meta);

        AuditLog::create([
            'salon_id'   => $tenant?->id,
            'user_id'    => $user?->id,
            'action'     => $action,
            'entity_type'=> $type,
            'entity_id'  => $id,
            'meta'       => $meta ?: null,
            'ip'         => $req?->ip(),
            'ua'         => substr($req?->header('User-Agent','') ?? '', 0, 255),
            'method'     => $req?->method(),
            'path'       => substr($req?->path() ?? '', 0, 255),
        ]);
    }

    protected static function sanitizeMeta(array $meta): array
    {
        // Entferne bekannte sensitive Keys
        $blocked = ['card','iban','password','token','secret','payload_raw','email','phone'];
        $clean = [];
        foreach ($meta as $k=>$v) {
            if (in_array(strtolower((string)$k), $blocked, true)) continue;
            if (is_scalar($v) || is_null($v)) { $clean[$k] = $v; continue; }
            $clean[$k] = json_decode(json_encode($v), true); // flach serialisieren
        }
        return $clean;
    }
}