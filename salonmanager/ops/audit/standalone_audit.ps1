# Standalone Audit Script for SalonManager
# Runs without dependencies to check production readiness

Write-Host "=== SalonManager Production Readiness Audit ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
Write-Host ""

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$backend = Join-Path $root "salonmanager\backend"
$frontend = Join-Path $root "frontend"
$ops = Join-Path $root "ops"

# Create audit directory
$auditDir = Join-Path $ops "audit"
if (!(Test-Path $auditDir)) {
    New-Item -ItemType Directory -Path $auditDir -Force | Out-Null
}

$report = @{}

# 1. Check for salon_id in database migrations
Write-Host "1. Checking tenant isolation (salon_id)..." -ForegroundColor Yellow
$migrationFiles = Get-ChildItem -Path (Join-Path $backend "database\migrations") -Filter "*.php" -Recurse
$tablesWithSalonId = @()
$tablesWithoutSalonId = @()

foreach ($file in $migrationFiles) {
    $content = Get-Content $file.FullName -Raw
    $filename = $file.Name
    
    # Extract table name from migration
    $tableName = $null
    if ($filename -match 'create_(\w+)_table') {
        $tableName = $matches[1]
    } elseif ($content -match 'table\([''""]([^''""]+)[''""]') {
        $tableName = $matches[1]
    }
    
    if ($tableName) {
        if ($content -match 'salon_id') {
            $tablesWithSalonId += $tableName
        } else {
            $tablesWithoutSalonId += $tableName
        }
    }
}

$report.tenant = @{
    tables_with_salon_id = $tablesWithSalonId.Count
    tables_without_salon_id = $tablesWithoutSalonId.Count
    missing_tables = $tablesWithoutSalonId
}

Write-Host "   Tables with salon_id: $($tablesWithSalonId.Count)" -ForegroundColor White
Write-Host "   Tables without salon_id: $($tablesWithoutSalonId.Count)" -ForegroundColor White

# 2. Check API routes for protection
Write-Host "`n2. Checking API route protection..." -ForegroundColor Yellow
$apiFile = Join-Path $backend "routes\api.php"
$apiContent = if (Test-Path $apiFile) { Get-Content $apiFile -Raw } else { "" }

$protectedRoutes = 0
$unprotectedRoutes = 0
$unguardedRoutes = @()

if ($apiContent) {
    $lines = $apiContent -split "`n"
    foreach ($line in $lines) {
        if ($line -match 'Route::' -and $line -match 'api/v1') {
            if ($line -match 'auth:sanctum' -and $line -match 'tenant.required') {
                $protectedRoutes++
            } else {
                $unprotectedRoutes++
                $unguardedRoutes += $line.Trim()
            }
        }
    }
}

$report.routes = @{
    protected_routes = $protectedRoutes
    unprotected_routes = $unprotectedRoutes
    unguarded_routes = $unguardedRoutes
}

Write-Host "   Protected routes: $protectedRoutes" -ForegroundColor White
Write-Host "   Unprotected routes: $unprotectedRoutes" -ForegroundColor White

# 3. Check security middleware
Write-Host "`n3. Checking security implementation..." -ForegroundColor Yellow
$middlewareDir = Join-Path $backend "app\Http\Middleware"
$securityChecks = @{
    csp_middleware = Test-Path (Join-Path $middlewareDir "SecureHeaders.php")
    throttle_middleware = Test-Path (Join-Path $middlewareDir "ThrottleRequests.php")
    tenant_middleware = Test-Path (Join-Path $middlewareDir "TenantRequired.php")
}

$report.security = $securityChecks

foreach ($check in $securityChecks.GetEnumerator()) {
    $status = if ($check.Value) { "OK" } else { "MISSING" }
    $color = if ($check.Value) { "Green" } else { "Red" }
    Write-Host "   $($check.Key): $status" -ForegroundColor $color
}

# 4. Check PWA implementation
Write-Host "`n4. Checking PWA implementation..." -ForegroundColor Yellow
$pwaChecks = @{
    manifest_exists = Test-Path (Join-Path $frontend "web\manifest.json")
    icon_192 = Test-Path (Join-Path $frontend "web\icons\icon-192.png")
    icon_512 = Test-Path (Join-Path $frontend "web\icons\icon-512.png")
    icon_maskable = Test-Path (Join-Path $frontend "web\icons\icon-maskable.png")
}

$report.pwa = $pwaChecks

foreach ($check in $pwaChecks.GetEnumerator()) {
    $status = if ($check.Value) { "OK" } else { "MISSING" }
    $color = if ($check.Value) { "Green" } else { "Red" }
    Write-Host "   $($check.Key): $status" -ForegroundColor $color
}

# 5. Check for critical missing files
Write-Host "`n5. Checking critical files..." -ForegroundColor Yellow
$criticalFiles = @{
    docker_compose = Test-Path (Join-Path $root "docker-compose.yml")
    github_actions = Test-Path (Join-Path $root ".github\workflows")
    env_example = Test-Path (Join-Path $backend ".env.example")
    readme = Test-Path (Join-Path $root "README.md")
}

$report.critical_files = $criticalFiles

foreach ($file in $criticalFiles.GetEnumerator()) {
    $status = if ($file.Value) { "OK" } else { "MISSING" }
    $color = if ($file.Value) { "Green" } else { "Red" }
    Write-Host "   $($file.Key): $status" -ForegroundColor $color
}

# 6. Check test coverage
Write-Host "`n6. Checking test coverage..." -ForegroundColor Yellow
$testFiles = Get-ChildItem -Path (Join-Path $backend "tests") -Filter "*.php" -Recurse
$testCount = $testFiles.Count

$featureTests = (Get-ChildItem -Path (Join-Path $backend "tests\Feature") -Filter "*.php" -ErrorAction SilentlyContinue).Count
$unitTests = (Get-ChildItem -Path (Join-Path $backend "tests\Unit") -Filter "*.php" -ErrorAction SilentlyContinue).Count

$report.tests = @{
    test_files = $testCount
    has_feature_tests = $featureTests -gt 0
    has_unit_tests = $unitTests -gt 0
}

Write-Host "   Test files: $testCount" -ForegroundColor White
Write-Host "   Feature tests: $(if ($featureTests -gt 0) { 'YES' } else { 'NO' })" -ForegroundColor White
Write-Host "   Unit tests: $(if ($unitTests -gt 0) { 'YES' } else { 'NO' })" -ForegroundColor White

# Generate report
Write-Host "`n=== Generating Report ===" -ForegroundColor Green
$reportContent = @"
# SalonManager Production Audit Report
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Summary
- Tables with salon_id: $($report.tenant.tables_with_salon_id)
- Tables without salon_id: $($report.tenant.tables_without_salon_id)
- Protected API routes: $($report.routes.protected_routes)
- Unprotected API routes: $($report.routes.unprotected_routes)
- Test files: $($report.tests.test_files)

## Critical Issues
"@

if ($report.tenant.tables_without_salon_id -gt 0) {
    $reportContent += "`n- $($report.tenant.tables_without_salon_id) tables missing salon_id (tenant isolation)"
}
if ($report.routes.unprotected_routes -gt 0) {
    $reportContent += "`n- $($report.routes.unprotected_routes) API routes not properly protected"
}
if (!$report.security.csp_middleware) {
    $reportContent += "`n- CSP middleware missing"
}
if (!$report.security.tenant_middleware) {
    $reportContent += "`n- Tenant middleware missing"
}
if (!$report.critical_files.docker_compose) {
    $reportContent += "`n- Docker configuration missing"
}
if (!$report.critical_files.github_actions) {
    $reportContent += "`n- CI/CD pipeline missing"
}

$reportContent | Out-File -FilePath (Join-Path $auditDir "report.md") -Encoding UTF8
$report | ConvertTo-Json -Depth 10 | Out-File -FilePath (Join-Path $auditDir "audit_data.json") -Encoding UTF8

Write-Host "Report saved to: $(Join-Path $auditDir 'report.md')" -ForegroundColor Green
Write-Host "Data saved to: $(Join-Path $auditDir 'audit_data.json')" -ForegroundColor Green

Write-Host "`n=== Audit Complete ===" -ForegroundColor Green
