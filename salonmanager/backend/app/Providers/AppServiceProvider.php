<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton('audit', fn() => new \App\Support\Audit\Audit());
        
        // AI Recommender binding based on environment configuration
        $recommenderType = config('app.ai_recommender', 'null');
        $this->app->bind(\App\Domain\Gallery\AI\Recommendations::class, function () use ($recommenderType) {
            return match ($recommenderType) {
                'null' => new \App\Services\Gallery\AI\NullRecommender(),
                'vertex' => new \App\Services\Gallery\AI\VertexRecommender(), // Future implementation
                'openai' => new \App\Services\Gallery\AI\OpenAIRecommender(), // Future implementation
                'custom' => new \App\Services\Gallery\AI\CustomRecommender(), // Future implementation
                default => new \App\Services\Gallery\AI\NullRecommender(),
            };
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        \App\Models\ProductPrice::observe(\App\Observers\ProductPriceObserver::class);
        
        // Prevent N+1 queries in non-production environments
        if (!app()->isProduction()) {
            \Illuminate\Database\Eloquent\Model::preventLazyLoading();
        }
    }
}