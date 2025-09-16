<?php

namespace App\Http\Controllers\Media;

use App\Http\Controllers\Controller;
use App\Http\Requests\Media\InitiateUploadRequest;
use App\Http\Requests\Media\FinalizeUploadRequest;
use App\Models\MediaFile;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Carbon;

class UploadController extends Controller
{
    /**
     * POST /api/v1/media/uploads/initiate
     */
    public function initiate(InitiateUploadRequest $request)
    {
        $validated = $request->validated();
        $salon = app('tenant');
        $ext = pathinfo($validated['filename'], PATHINFO_EXTENSION) ?: 'bin';
        $key = "salons/{$salon->id}/uploads/" . date('Y/m/d') . "/" . Str::uuid() . ".$ext";
        $expires = now()->addMinutes(10);

        // presigned PUT
        $disk = Storage::disk('media');
        $client = $disk->getClient();           // Aws\S3\S3Client
        $bucket = config('filesystems.disks.media.bucket');
        $cmd = $client->getCommand('PutObject', [
            'Bucket' => $bucket,
            'Key' => $key,
            'ContentType' => $validated['mime'],
            'ACL' => 'private'
        ]);
        $presigned = $client->createPresignedRequest($cmd, $expires);
        $url = (string) $presigned->getUri();

        return response()->json([
            'upload_url' => $url,
            'key' => $key,
            'expires_at' => $expires->toIso8601String(),
            'headers' => ['Content-Type' => $validated['mime']],
        ]);
    }

    /**
     * POST /api/v1/media/uploads/finalize
     */
    public function finalize(FinalizeUploadRequest $request)
    {
        $validated = $request->validated();
        $salonId = app('tenant')->id;

        // create record
        $file = MediaFile::create([
            'salon_id' => $salonId,
            'owner_type' => $validated['owner_type'],
            'owner_id' => $validated['owner_id'],
            'disk' => 'media',
            'path' => $validated['key'],
            'mime' => $validated['mime'],
            'bytes' => $validated['bytes'],
            'width' => $validated['width'] ?? null,
            'height' => $validated['height'] ?? null,
            'visibility' => $validated['visibility'] ?? 'internal',
            'consent_required' => $validated['consent_required'] ?? false,
            'consent_status' => ($validated['consent_required'] ?? false) ? 'requested' : 'approved',
            'subject_user_id' => $validated['subject_user_id'] ?? null,
            'subject_name' => $validated['subject_name'] ?? null,
            'subject_contact' => $validated['subject_contact'] ?? null,
            'retention_until' => ($validated['consent_required'] ?? false) ? Carbon::now()->addMonths(12) : null,
        ]);

        // queue thumbnail/exif
        dispatch(new \App\Jobs\Media\ProcessImageJob($file->id));

        // audit
        event(new \App\Events\Audit\Generic('media.upload', 'MediaFile', $file->id, ['bytes' => $file->bytes]));

        return response()->json([
            'file' => $file,
            'url' => $file->url(),
            'thumb' => $file->variants['thumb'] ?? null
        ], 201);
    }

    /**
     * GET /api/v1/media/files/{file} (meta)
     */
    public function show(MediaFile $file)
    {
        $this->authorize('view', $file);
        return response()->json([
            'file' => $file,
            'url' => $file->url(),
            'thumb' => $file->variants['thumb'] ?? null
        ]);
    }

    /**
     * DELETE /api/v1/media/files/{file} (soft delete, consent aware)
     */
    public function destroy(Request $request, MediaFile $file)
    {
        $this->authorize('manage', $file);
        $file->delete(); // soft
        event(new \App\Events\Audit\Generic('media.delete', 'MediaFile', $file->id, []));
        return response()->json(['ok' => true]);
    }
}