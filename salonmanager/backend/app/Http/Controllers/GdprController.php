<?php

namespace App\Http\Controllers;

use App\Jobs\Gdpr\BuildExportJob;
use App\Models\{GdprRequest, User};
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;

class GdprController extends Controller
{
    /** POST /api/v1/gdpr/export (auth: customer/self) */
    public function requestExport(Request $r)
    {
        $u = $r->user();
        $salonId = app('tenant')->id;

        $g = GdprRequest::create([
            'salon_id' => $salonId,
            'user_id' => $u->id,
            'type' => 'export',
            'status' => 'pending'
        ]);

        dispatch(new BuildExportJob($g->id));
        event(new \App\Events\Gdpr\ExportRequested(userId: $u->id, gdprId: $g->id));
        \App\Support\Audit\Audit::write('gdpr.export.request', 'User', $u->id, []);

        return response()->json(['gdpr_id' => $g->id, 'status' => $g->status], 202);
    }

    /** GET /api/v1/gdpr/exports/{gdpr} (auth: self; returns meta/status) */
    public function show(Request $r, GdprRequest $gdpr)
    {
        $this->authorizeGdpr($gdpr, $r->user());
        return response()->json([
            'id' => $gdpr->id,
            'status' => $gdpr->status,
            'artifact_path' => $gdpr->artifact_path,
            'meta' => $gdpr->meta
        ]);
    }

    /** GET /api/v1/gdpr/exports/{gdpr}/download (auth: self; force file) */
    public function download(Request $r, GdprRequest $gdpr)
    {
        $this->authorizeGdpr($gdpr, $r->user());
        if ($gdpr->status !== 'done' || !$gdpr->artifact_path) {
            abort(404);
        }
        $disk = Storage::disk('exports');
        if (!$disk->exists($gdpr->artifact_path)) {
            abort(404);
        }
        \App\Support\Audit\Audit::write('gdpr.export.download', 'GdprRequest', $gdpr->id, []);
        return response($disk->get($gdpr->artifact_path), 200, [
            'Content-Type' => 'application/zip',
            'Content-Disposition' => 'attachment; filename="gdpr_' . $gdpr->id . '.zip"'
        ]);
    }

    /** POST /api/v1/gdpr/delete (auth: self) */
    public function requestDelete(Request $r)
    {
        $u = $r->user();
        $salonId = app('tenant')->id;
        $g = GdprRequest::create([
            'salon_id' => $salonId,
            'user_id' => $u->id,
            'type' => 'delete',
            'status' => 'pending'
        ]);
        event(new \App\Events\Gdpr\DeletionRequested(userId: $u->id, gdprId: $g->id));
        \App\Support\Audit\Audit::write('gdpr.delete.request', 'User', $u->id, []);
        return response()->json(['gdpr_id' => $g->id, 'status' => 'pending']);
    }

    /** POST /api/v1/gdpr/delete/{gdpr}/confirm (auth: owner/platform_admin/salon_owner) */
    public function confirmDelete(Request $r, GdprRequest $gdpr)
    {
        $this->authorizeAdmin($r->user());
        if ($gdpr->type !== 'delete' || $gdpr->status !== 'pending') {
            abort(400);
        }

        // ⚠️ Anonymisierung – NICHT Rechnungen löschen (GoBD)
        $user = User::find($gdpr->user_id);
        if ($user) {
            $user->name = '[deleted]';
            $user->email = null;
            $user->phone = null;
            // TODO(ASK): weitere PII-Felder? (address, birthday...)
            $user->save();
        }

        $gdpr->status = 'done';
        $gdpr->save();
        event(new \App\Events\Gdpr\DeletionConfirmed(userId: $gdpr->user_id, gdprId: $gdpr->id));
        \App\Support\Audit\Audit::write('gdpr.delete.confirm', 'User', $gdpr->user_id, []);

        return response()->json(['ok' => true, 'status' => 'done']);
    }

    private function authorizeGdpr(GdprRequest $g, $user): void
    {
        if ($g->user_id !== $user->id && !$user->hasAnyRole(['owner', 'platform_admin', 'salon_owner'])) {
            abort(403);
        }
    }

    private function authorizeAdmin($user): void
    {
        if (!$user->hasAnyRole(['owner', 'platform_admin', 'salon_owner'])) {
            abort(403);
        }
    }
}