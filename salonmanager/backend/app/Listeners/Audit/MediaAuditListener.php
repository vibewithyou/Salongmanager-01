<?php

namespace App\Listeners\Audit;

use App\Support\Audit\Audit;

class MediaAuditListener
{
    public function uploaded($event): void {
        Audit::write('media.upload', 'MediaFile', $event->mediaFileId, []);
    }
    public function consentRequested($event): void {
        Audit::write('media.consent.requested', 'MediaFile', $event->mediaFileId, []);
    }
    public function consentApproved($event): void {
        Audit::write('media.consent.approved', 'MediaFile', $event->mediaFileId, []);
    }
    public function consentRevoked($event): void {
        Audit::write('media.consent.revoked', 'MediaFile', $event->mediaFileId, []);
    }
}