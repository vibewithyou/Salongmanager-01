<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Symfony\Component\HttpFoundation\Response;

class ResponseCache
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next, int $ttl = 60): Response
    {
        // Only cache GET requests
        if (!$request->isMethod('GET')) {
            return $next($request);
        }

        // Skip caching for authenticated users on sensitive endpoints
        if ($this->shouldSkipCaching($request)) {
            return $next($request);
        }

        $cacheKey = $this->generateCacheKey($request);
        
        // Try to get cached response
        $cached = Cache::get($cacheKey);
        if ($cached) {
            $response = response($cached['content'], $cached['status'], $cached['headers']);
            $response->headers->set('X-Response-Cache', 'HIT');
            $response->headers->set('X-Cache-TTL', $ttl);
            return $response;
        }

        // Process request
        $response = $next($request);

        // Only cache successful responses
        if ($response->getStatusCode() >= 200 && $response->getStatusCode() < 300) {
            $this->cacheResponse($cacheKey, $response, $ttl);
            $response->headers->set('X-Response-Cache', 'MISS');
            $response->headers->set('X-Cache-TTL', $ttl);
        }

        return $response;
    }

    /**
     * Determine if we should skip caching for this request
     */
    private function shouldSkipCaching(Request $request): bool
    {
        // Skip for authenticated users on sensitive endpoints
        if ($request->user() && $this->isSensitiveEndpoint($request)) {
            return true;
        }

        // Skip for certain route patterns
        $excludedPatterns = [
            'api/v1/auth/*',
            'api/v1/payments/*',
            'api/v1/webhooks/*',
            'api/v1/admin/*',
        ];

        foreach ($excludedPatterns as $pattern) {
            if ($request->is($pattern)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Check if endpoint is sensitive and should not be cached for authenticated users
     */
    private function isSensitiveEndpoint(Request $request): bool
    {
        $sensitivePatterns = [
            'api/v1/bookings/*',
            'api/v1/invoices/*',
            'api/v1/customers/*',
            'api/v1/reports/*',
        ];

        foreach ($sensitivePatterns as $pattern) {
            if ($request->is($pattern)) {
                return true;
            }
        }

        return false;
    }

    /**
     * Generate cache key for request
     */
    private function generateCacheKey(Request $request): string
    {
        $key = 'response_cache:' . md5($request->fullUrl());
        
        // Include user ID in key for user-specific content
        if ($request->user()) {
            $key .= ':' . $request->user()->id;
        }

        return $key;
    }

    /**
     * Cache the response
     */
    private function cacheResponse(string $key, Response $response, int $ttl): void
    {
        $cacheData = [
            'content' => $response->getContent(),
            'status' => $response->getStatusCode(),
            'headers' => $response->headers->all(),
        ];

        Cache::put($key, $cacheData, $ttl);
    }
}
