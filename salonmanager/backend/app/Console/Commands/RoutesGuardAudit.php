<?php
namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Route;

class RoutesGuardAudit extends Command {
  protected $signature = 'audit:routes';
  protected $description = 'Verify that /api/v1 routes have auth:sanctum and tenant.required';

  public function handle(): int {
    $bad = [];
    foreach (Route::getRoutes() as $r) {
      $uri = $r->uri();
      if (!str_starts_with($uri,'api/v1/')) continue;
      $m = implode(',', $r->gatherMiddleware());
      if (str_contains($m,'auth:sanctum')===false || str_contains($m,'tenant.required')===false) {
        $bad[] = [$uri,$m];
      }
    }
    @mkdir(base_path('../ops/audit'),0777,true);
    $out = collect($bad)->map(fn($x)=>$x[0].' :: '.$x[1])->implode("\n");
    file_put_contents(base_path('../ops/audit/unguarded_routes.txt'), $out);
    $this->info("unguarded: ".count($bad));
    return self::SUCCESS;
  }
}
