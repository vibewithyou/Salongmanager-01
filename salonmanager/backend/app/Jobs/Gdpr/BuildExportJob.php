<?php

namespace App\Jobs\Gdpr;

use App\Models\{GdprRequest, User};
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Support\Facades\Storage;
use ZipArchive;

class BuildExportJob implements ShouldQueue
{
    use Queueable;

    public $tries = 3;
    public $backoff = [10, 60, 180]; // Sekunden

    public function __construct(public int $gdprId) {}

    public function handle(): void
    {
        $req = GdprRequest::find($this->gdprId);
        if (!$req) return;

        $req->status = 'processing';
        $req->save();

        $user = User::with([
            // TODO(ASK): confirm relation names if different
            'bookings', 'invoices', 'reviews', 'loyaltyCards', 'loyaltyCards.transactions'
        ])->find($req->user_id);

        // Daten sammeln (ohne hochsensible Felder)
        $payload = [
            'profile'   => $user ? $user->only(['id', 'name', 'email', 'phone', 'created_at']) : [],
            'bookings'  => $user?->bookings?->map->only(['id', 'start_at', 'status', 'services'])->values() ?? [],
            'invoices'  => $user?->invoices?->map->only(['id', 'number', 'total', 'currency', 'created_at'])->values() ?? [],
            'reviews'   => $user?->reviews?->map->only(['id', 'rating', 'body', 'created_at'])->values() ?? [],
            'loyalty'   => $user?->loyaltyCards?->map(function($c) {
                return [
                    'id' => $c->id, 
                    'balance' => $c->balance,
                    'transactions' => $c->transactions->map->only(['id', 'delta', 'reason', 'created_at'])->values(),
                ];
            })->values() ?? [],
        ];

        // JSON schreiben
        $json = json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        $tenantId = $req->salon_id;
        $dir = "salon_{$tenantId}/user_{$req->user_id}/" . date('Y/m/d');
        $tmpJson = tempnam(sys_get_temp_dir(), 'gdpr_') . '.json';
        file_put_contents($tmpJson, $json);

        // ZIP bauen
        $zipName = "gdpr_{$req->id}.zip";
        $tmpZip = tempnam(sys_get_temp_dir(), 'gdpr_');
        $zip = new ZipArchive();
        $zip->open($tmpZip, ZipArchive::OVERWRITE);
        $zip->addFile($tmpJson, 'data.json');

        // optional: Medien-Metadaten (keine Originalbilder um Größe zu sparen)
        // TODO(ASK): include media metadata? if yes, add minimal JSON (file ids, captions)
        $zip->close();

        // auf Disk verschieben
        $path = $dir . '/' . $zipName;
        Storage::disk('exports')->put($path, file_get_contents($tmpZip));

        unlink($tmpJson);
        @unlink($tmpZip);

        $req->artifact_path = $path;
        $req->status = 'done';
        $req->meta = ['size_bytes' => Storage::disk('exports')->size($path)];
        $req->save();

        // Audit/Notify
        event(new \App\Events\Gdpr\Exported(userId: $req->user_id, gdprId: $req->id));
    }
}