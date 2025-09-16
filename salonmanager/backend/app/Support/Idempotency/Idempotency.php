<?php

namespace App\Support\Idempotency;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class Idempotency
{
    /**
     * Execute a callback only once per idempotency key
     */
    public static function once(string $key, string $scope, callable $callback, int $ttlMinutes = 60)
    {
        $fullKey = "idempotency:{$scope}:{$key}";
        
        // Check cache first for performance
        if (Cache::has($fullKey)) {
            $cached = Cache::get($fullKey);
            return $cached['response'];
        }
        
        // Check database for persistence
        $existing = DB::table('idempotency_keys')
            ->where('key', $key)
            ->where('scope', $scope)
            ->where(function ($query) use ($ttlMinutes) {
                $query->whereNull('expires_at')
                    ->orWhere('expires_at', '>', now());
            })
            ->first();
            
        if ($existing) {
            $response = json_decode($existing->response, true);
            
            // Cache for performance
            Cache::put($fullKey, [
                'response' => $response,
                'expires_at' => $existing->expires_at
            ], $ttlMinutes);
            
            return $response;
        }
        
        // Execute callback and store result
        try {
            $response = $callback();
            
            $expiresAt = now()->addMinutes($ttlMinutes);
            
            DB::table('idempotency_keys')->insert([
                'key' => $key,
                'scope' => $scope,
                'response' => json_encode($response),
                'expires_at' => $expiresAt,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            
            // Cache for performance
            Cache::put($fullKey, [
                'response' => $response,
                'expires_at' => $expiresAt
            ], $ttlMinutes);
            
            return $response;
            
        } catch (\Exception $e) {
            // Don't store failed responses
            throw $e;
        }
    }
    
    /**
     * Generate a unique idempotency key
     */
    public static function generateKey(string $prefix = 'req'): string
    {
        return $prefix . '_' . uniqid() . '_' . time();
    }
    
    /**
     * Clean up expired idempotency keys
     */
    public static function cleanup(): int
    {
        $deleted = DB::table('idempotency_keys')
            ->where('expires_at', '<', now())
            ->delete();
            
        return $deleted;
    }
}