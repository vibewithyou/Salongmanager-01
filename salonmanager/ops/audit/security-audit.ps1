# Security Audit Script for SalonManager
# Checks security middleware, headers, and configurations

Write-Host "=== SalonManager Security Audit ===" -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "salonmanager/backend/artisan")) {
    Write-Host "Error: Please run from project root directory" -ForegroundColor Red
    exit 1
}

Write-Host "Running security audit..." -ForegroundColor Yellow

# Check security middleware
$securityChecks = @{}

# Check for SecureHeaders middleware
$secureHeadersFile = "salonmanager/backend/app/Http/Middleware/SecureHeaders.php"
if (Test-Path $secureHeadersFile) {
    $content = Get-Content $secureHeadersFile -Raw
    $securityChecks["CSP_Headers"] = $content -match "Content-Security-Policy"
    $securityChecks["HSTS_Headers"] = $content -match "Strict-Transport-Security"
    $securityChecks["X_Frame_Options"] = $content -match "X-Frame-Options"
    $securityChecks["X_Content_Type_Options"] = $content -match "X-Content-Type-Options"
} else {
    $securityChecks["SecureHeaders_Middleware"] = $false
}

# Check for rate limiting
$rateLimitFile = "salonmanager/backend/app/Http/Middleware/ScopeRateLimit.php"
$securityChecks["Rate_Limiting"] = Test-Path $rateLimitFile

# Check for role middleware
$roleMiddlewareFile = "salonmanager/backend/app/Http/Middleware/RequireRole.php"
$securityChecks["Role_Middleware"] = Test-Path $roleMiddlewareFile

# Check for tenant middleware
$tenantMiddlewareFile = "salonmanager/backend/app/Http/Middleware/TenantRequired.php"
$securityChecks["Tenant_Middleware"] = Test-Path $tenantMiddlewareFile

# Check for webhook signature verification
$webhookFile = "salonmanager/backend/app/Http/Controllers/PaymentWebhookController.php"
if (Test-Path $webhookFile) {
    $content = Get-Content $webhookFile -Raw
    $securityChecks["Webhook_Signature_Verification"] = $content -match "signature"
} else {
    $securityChecks["Webhook_Signature_Verification"] = $false
}

# Check for audit logging
$auditFile = "salonmanager/backend/app/Support/Audit"
$securityChecks["Audit_Logging"] = Test-Path $auditFile

# Check for CORS configuration
$corsFile = "salonmanager/backend/config/cors.php"
$securityChecks["CORS_Configuration"] = Test-Path $corsFile

# Check for Sanctum configuration
$sanctumFile = "salonmanager/backend/config/sanctum.php"
$securityChecks["Sanctum_Configuration"] = Test-Path $sanctumFile

# Generate security report
$securityReport = @"
# Security Audit Report
Generated: $(Get-Date)

## Security Checks
"@

foreach ($check in $securityChecks.GetEnumerator()) {
    $status = if ($check.Value) { "✅ PASS" } else { "❌ FAIL" }
    $securityReport += "`n- $($check.Key): $status"
}

$securityReport += @"

## Summary
- Total Checks: $($securityChecks.Count)
- Passed: $(($securityChecks.Values | Where-Object { $_ -eq $true }).Count)
- Failed: $(($securityChecks.Values | Where-Object { $_ -eq $false }).Count)

## Recommendations
$(if (($securityChecks.Values | Where-Object { $_ -eq $false }).Count -gt 0) {
    "1. Fix failed security checks
2. Implement missing security middleware
3. Configure proper CORS settings
4. Set up comprehensive audit logging
5. Test webhook signature verification"
} else {
    "✅ All security checks passed"
})
"@

$securityReport | Out-File -FilePath "ops/audit/security-audit-report.md" -Encoding UTF8

Write-Host "Security audit complete" -ForegroundColor Green
Write-Host "Report saved to ops/audit/security-audit-report.md" -ForegroundColor Green

$failedChecks = ($securityChecks.Values | Where-Object { $_ -eq $false }).Count
if ($failedChecks -gt 0) {
    Write-Host "⚠️  WARNING: $failedChecks security checks failed" -ForegroundColor Yellow
} else {
    Write-Host "✅ All security checks passed" -ForegroundColor Green
}
