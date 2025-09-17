# PowerShell Audit Script for Salongmanager
$ROOT = Get-Location
Write-Host "Repo root: $ROOT"

Write-Host "== Basic tree =="
Get-ChildItem -Path $ROOT -Recurse -Directory -Depth 3 | Where-Object { $_.Name -notmatch "vendor|node_modules|build|\.dart_tool|\.git|ios|android" } | Select-Object FullName

Write-Host "== Orphan check (Laravel files outside salonmanager/backend) =="
Get-ChildItem -Path $ROOT -Recurse -Directory -Depth 3 | Where-Object { $_.Name -eq "app" -or $_.Name -eq "database" } | Where-Object { $_.FullName -notlike "*salonmanager\backend*" }

Write-Host "== Grep TODO / FIXME / DUMMY =="
Get-ChildItem -Path $ROOT -Recurse -File | Where-Object { $_.Name -notlike "*.git*" -and $_.DirectoryName -notlike "*vendor*" } | Select-String -Pattern "TODO\(|TODO:|FIXME|DUMMY|PLACEHOLDER" -CaseSensitive:$false

Write-Host "== Composer validate =="
Set-Location "$ROOT\salonmanager\backend"
composer validate --no-check-lock

Write-Host "== Composer autoload (optimize) =="
composer dump-autoload -o

Write-Host "== PHP & Laravel info =="
php -v
php artisan --version

Write-Host "== Route list (export to ops/audit/routes.txt) =="
php artisan route:list | Out-File -FilePath "$ROOT\ops\audit\routes.txt" -Encoding UTF8
Write-Host "Route list saved to ops/audit/routes.txt"

Write-Host "== Config cache (non-destructive) =="
php artisan config:cache
php artisan route:cache

Write-Host "== Migrate (DRY RUN preview) =="
php artisan migrate --pretend

Write-Host "== Tests (Feature only, stop on first fail) =="
php artisan test --testsuite=Feature --stop-on-failure

Write-Host "== Composer security audit =="
composer audit

Write-Host "== Flutter doctor/analyze =="
Set-Location "$ROOT\salonmanager\frontend"
flutter --version
flutter doctor -v
flutter pub get
flutter analyze

Write-Host "== Flutter PWA manifest quick check =="
if (Test-Path "web\manifest.json") {
    $manifest = Get-Content "web\manifest.json" | ConvertFrom-Json
    Write-Host "Name: $($manifest.name)"
    Write-Host "Icons count: $($manifest.icons.Count)"
} else {
    Write-Host "manifest.json missing"
}

Write-Host "== Icon placeholders present? =="
if (Test-Path "web\icons") {
    Get-ChildItem "web\icons"
} else {
    Write-Host "icons folder missing"
}

Write-Host "== DONE =="
Set-Location $ROOT
