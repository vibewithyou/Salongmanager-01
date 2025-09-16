<?php

namespace App\Domain\Gallery\AI;

interface Recommendations
{
    /**
     * Suggest services for a photo based on its metadata, album, or tags
     *
     * @param int $photoId The ID of the gallery photo
     * @return array Array of suggested services with their details
     */
    public function suggestServicesForPhoto(int $photoId): array;
}
