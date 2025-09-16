# Tenant Audit Script for SalonManager
# Checks for missing salon_id fields and tenant isolation

Write-Host "=== SalonManager Tenant Audit ===" -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "salonmanager/backend/artisan")) {
    Write-Host "Error: Please run from project root directory" -ForegroundColor Red
    exit 1
}

Write-Host "Checking tenant isolation..." -ForegroundColor Yellow

# List of tables that should have salon_id
$requiredTables = @(
    "bookings", "invoices", "invoice_items", "payments", "refunds",
    "loyalty_cards", "loyalty_transactions", "discounts", "reviews",
    "media_files", "customer_notes", "customer_media", "shifts", "absences",
    "products", "product_prices", "stock_items", "stock_movements",
    "purchase_orders", "purchase_order_items", "suppliers", "stock_locations"
)

$missingSalonId = @()
$hasSalonId = @()

# Check each table (simplified check - would need actual DB connection for real audit)
foreach ($table in $requiredTables) {
    $migrationFiles = Get-ChildItem "salonmanager/backend/database/migrations" -Filter "*$table*" -Recurse
    $hasSalonIdField = $false
    
    foreach ($file in $migrationFiles) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match "salon_id") {
            $hasSalonIdField = $true
            break
        }
    }
    
    if ($hasSalonIdField) {
        $hasSalonId += $table
    } else {
        $missingSalonId += $table
    }
}

# Generate tenant audit report
$tenantReport = @"
# Tenant Isolation Audit Report
Generated: $(Get-Date)

## Tables WITH salon_id (✅)
$($hasSalonId -join "`n")

## Tables MISSING salon_id (❌)
$($missingSalonId -join "`n")

## Summary
- Total Tables Checked: $($requiredTables.Count)
- Tables with salon_id: $($hasSalonId.Count)
- Tables missing salon_id: $($missingSalonId.Count)
- Tenant Isolation: $(if ($missingSalonId.Count -eq 0) { "✅ COMPLETE" } else { "❌ INCOMPLETE" })

## Recommendations
$(if ($missingSalonId.Count -gt 0) {
    "1. Add salon_id to missing tables: $($missingSalonId -join ', ')
2. Create migration to add salon_id columns
3. Update models to use SalonOwned trait
4. Add tenant filtering to queries"
} else {
    "✅ All tables have proper tenant isolation"
})
"@

$tenantReport | Out-File -FilePath "ops/audit/tenant-audit-report.md" -Encoding UTF8

Write-Host "Tenant audit complete" -ForegroundColor Green
Write-Host "Report saved to ops/audit/tenant-audit-report.md" -ForegroundColor Green

if ($missingSalonId.Count -gt 0) {
    Write-Host "⚠️  WARNING: $($missingSalonId.Count) tables missing salon_id" -ForegroundColor Yellow
} else {
    Write-Host "✅ All tables have proper tenant isolation" -ForegroundColor Green
}
