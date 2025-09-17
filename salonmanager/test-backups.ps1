# Backup Testing Script
# Tests the backup system functionality

Write-Host "💾 Testing Backup System..." -ForegroundColor Yellow

# Test backup creation
Write-Host "Creating backup..." -ForegroundColor Cyan
docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan backup:run

# List available backups
Write-Host "`nListing available backups..." -ForegroundColor Cyan
docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan backup:list

# Test backup cleanup (optional)
Write-Host "`nTesting backup cleanup..." -ForegroundColor Cyan
docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan backup:clean

Write-Host "`n✅ Backup testing completed!" -ForegroundColor Green
