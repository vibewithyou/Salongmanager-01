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