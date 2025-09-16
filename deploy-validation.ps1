# SalonManager Production Validation Script
# Run this after starting Docker Desktop

Write-Host "🚀 SalonManager Production Validation" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if Docker is running
Write-Host "`n1. Checking Docker status..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker is running: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Build and start containers
Write-Host "`n2. Building and starting containers..." -ForegroundColor Yellow
docker compose -f docker-compose.prod.yml build app queue scheduler web
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to build containers" -ForegroundColor Red
    exit 1
}

docker compose -f docker-compose.prod.yml up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start containers" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Containers started successfully" -ForegroundColor Green

# Wait for containers to be ready
Write-Host "`n3. Waiting for containers to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Generate application key
Write-Host "`n4. Generating application key..." -ForegroundColor Yellow
docker compose -f docker-compose.prod.yml exec -T app php artisan key:generate
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Warning: Failed to generate application key" -ForegroundColor Yellow
}

# Run migrations
Write-Host "`n5. Running database migrations..." -ForegroundColor Yellow
docker compose -f docker-compose.prod.yml exec -T app php artisan migrate --force
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to run migrations" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Migrations completed successfully" -ForegroundColor Green

# Test health endpoint
Write-Host "`n6. Testing health endpoint..." -ForegroundColor Yellow
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost/health" -Method GET
    Write-Host "✅ Health check passed: $($healthResponse.status)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test webhook endpoint
Write-Host "`n7. Testing webhook endpoint..." -ForegroundColor Yellow
try {
    $webhookResponse = Invoke-WebRequest -Uri "http://localhost/api/v1/payments/webhook" -Method POST -ErrorAction Stop
    Write-Host "⚠️  Webhook returned status: $($webhookResponse.StatusCode)" -ForegroundColor Yellow
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Webhook correctly rejected invalid request (400)" -ForegroundColor Green
    } else {
        Write-Host "❌ Webhook test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Run tests
Write-Host "`n8. Running tests..." -ForegroundColor Yellow
docker compose -f docker-compose.prod.yml exec -T app php artisan test --testsuite=Feature
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Feature tests passed" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some feature tests failed" -ForegroundColor Yellow
}

# Show container status
Write-Host "`n9. Container status:" -ForegroundColor Yellow
docker compose -f docker-compose.prod.yml ps

Write-Host "`n🎉 Validation complete!" -ForegroundColor Green
Write-Host "Check the results above. If all tests passed, the system is ready for production." -ForegroundColor Green
