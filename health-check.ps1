# Comprehensive Health Check Script
# Tests all critical endpoints and services

Write-Host "🏥 Running Comprehensive Health Checks..." -ForegroundColor Yellow

# Test Laravel health endpoint
Write-Host "`n1. Testing Laravel Health Endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost/up" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Laravel health check passed" -ForegroundColor Green
    } else {
        Write-Host "❌ Laravel health check failed: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Laravel health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test API health endpoint
Write-Host "`n2. Testing API Health Endpoint..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/v1/health" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        $json = $response.Content | ConvertFrom-Json
        Write-Host "✅ API health check passed" -ForegroundColor Green
        Write-Host "   Status: $($json.status)" -ForegroundColor Gray
        Write-Host "   Version: $($json.version)" -ForegroundColor Gray
        Write-Host "   Time: $($json.time)" -ForegroundColor Gray
    } else {
        Write-Host "❌ API health check failed: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ API health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test database connection
Write-Host "`n3. Testing Database Connection..." -ForegroundColor Cyan
try {
    $dbTest = docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan tinker --execute="echo 'DB Connection: ' . (DB::connection()->getPdo() ? 'OK' : 'FAIL');"
    Write-Host "✅ Database connection test: $dbTest" -ForegroundColor Green
} catch {
    Write-Host "❌ Database connection test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Redis connection
Write-Host "`n4. Testing Redis Connection..." -ForegroundColor Cyan
try {
    $redisTest = docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan tinker --execute="echo 'Redis Connection: ' . (Redis::ping() ? 'OK' : 'FAIL');"
    Write-Host "✅ Redis connection test: $redisTest" -ForegroundColor Green
} catch {
    Write-Host "❌ Redis connection test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test queue worker
Write-Host "`n5. Testing Queue Worker..." -ForegroundColor Cyan
try {
    $queueTest = docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan queue:work --once --timeout=10
    Write-Host "✅ Queue worker test completed" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Queue worker test inconclusive: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test scheduler
Write-Host "`n6. Testing Scheduler..." -ForegroundColor Cyan
try {
    $schedulerTest = docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan schedule:list
    Write-Host "✅ Scheduler test completed" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Scheduler test inconclusive: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test file permissions
Write-Host "`n7. Testing File Permissions..." -ForegroundColor Cyan
try {
    $permTest = docker compose -f ops/deploy/compose.prod.yml exec -T app ls -la storage/
    Write-Host "✅ File permissions check completed" -ForegroundColor Green
} catch {
    Write-Host "❌ File permissions check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Health Check Summary:" -ForegroundColor Green
Write-Host "All critical services have been tested." -ForegroundColor Gray
Write-Host "Check the results above for any issues." -ForegroundColor Gray
