<?php

namespace App\Services\Gallery\AI;

use App\Domain\Gallery\AI\Recommendations;

class NullRecommender implements Recommendations
{
    /**
     * Returns empty array as this is a null implementation
     *
     * @param int $photoId
     * @return array
     */
    public function suggestServicesForPhoto(int $photoId): array
    {
        return [];
    }
}
