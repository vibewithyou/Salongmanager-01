# Route List Generator for SalonManager Audit
# Generates comprehensive route list for security and functionality audit

Write-Host "=== SalonManager Route Audit ===" -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "salonmanager/backend/artisan")) {
    Write-Host "Error: Please run from project root directory" -ForegroundColor Red
    exit 1
}

# Generate route list
Write-Host "Generating route list..." -ForegroundColor Yellow
try {
    Set-Location "salonmanager/backend"
    php artisan route:list --json | Out-File -FilePath "../../ops/audit/routes.json" -Encoding UTF8
    php artisan route:list | Out-File -FilePath "../../ops/audit/routes.txt" -Encoding UTF8
    Set-Location "../.."
    Write-Host "Route list generated successfully" -ForegroundColor Green
} catch {
    Write-Host "Error generating route list: $_" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

# Analyze routes for security issues
Write-Host "Analyzing routes for security issues..." -ForegroundColor Yellow

$routes = Get-Content "ops/audit/routes.txt"
$unprotectedRoutes = @()
$missingTenantRoutes = @()

foreach ($route in $routes) {
    if ($route -match "api/v1" -and $route -notmatch "auth:sanctum") {
        $unprotectedRoutes += $route
    }
    if ($route -match "api/v1" -and $route -notmatch "tenant.required") {
        $missingTenantRoutes += $route
    }
}

# Generate security report
$securityReport = @"
# Route Security Audit Report
Generated: $(Get-Date)

## Unprotected API Routes (Missing auth:sanctum)
$($unprotectedRoutes -join "`n")

## Routes Missing Tenant Required
$($missingTenantRoutes -join "`n")

## Summary
- Total API Routes: $($routes | Where-Object { $_ -match "api/v1" } | Measure-Object).Count
- Unprotected Routes: $($unprotectedRoutes.Count)
- Missing Tenant: $($missingTenantRoutes.Count)
"@

$securityReport | Out-File -FilePath "ops/audit/route-security-report.md" -Encoding UTF8

Write-Host "Security analysis complete" -ForegroundColor Green
Write-Host "Reports saved to ops/audit/" -ForegroundColor Green
