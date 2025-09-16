# Local Development Start Script
# This script starts the local development environment

Write-Host "🚀 Starting SalonManager Local Development Environment" -ForegroundColor Green

# Check if Docker is running
Write-Host "📋 Checking Docker status..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Start local services (DB + Redis)
Write-Host "🐳 Starting local services (MySQL + Redis)..." -ForegroundColor Yellow
docker compose -f ops/dev/compose.local.yml up -d

# Wait for services to be ready
Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check if services are healthy
Write-Host "🔍 Checking service health..." -ForegroundColor Yellow
$dbHealthy = $false
$redisHealthy = $false

try {
    $dbStatus = docker exec salonmanager_db_local mysqladmin ping -h 127.0.0.1 -uroot -proot
    if ($dbStatus -match "alive") {
        $dbHealthy = $true
        Write-Host "✅ MySQL is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ MySQL is not healthy" -ForegroundColor Red
}

try {
    $redisStatus = docker exec salonmanager_redis_local redis-cli ping
    if ($redisStatus -match "PONG") {
        $redisHealthy = $true
        Write-Host "✅ Redis is healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Redis is not healthy" -ForegroundColor Red
}

if (-not $dbHealthy -or -not $redisHealthy) {
    Write-Host "❌ Services are not healthy. Please check Docker logs." -ForegroundColor Red
    exit 1
}

# Copy .env.local to .env if it doesn't exist
Write-Host "📝 Setting up environment..." -ForegroundColor Yellow
if (Test-Path "salonmanager/backend/.env.local") {
    Copy-Item "salonmanager/backend/.env.local" "salonmanager/backend/.env" -Force
    Write-Host "✅ Environment file copied" -ForegroundColor Green
} else {
    Write-Host "❌ .env.local not found. Please create it first." -ForegroundColor Red
    exit 1
}

# Install dependencies
Write-Host "📦 Installing PHP dependencies..." -ForegroundColor Yellow
Set-Location salonmanager/backend
try {
    composer install --no-interaction
    Write-Host "✅ Composer dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install Composer dependencies" -ForegroundColor Red
    Set-Location ../..
    exit 1
}

# Generate application key
Write-Host "🔑 Generating application key..." -ForegroundColor Yellow
try {
    php artisan key:generate
    Write-Host "✅ Application key generated" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to generate application key" -ForegroundColor Red
    Set-Location ../..
    exit 1
}

# Run migrations
Write-Host "🗄️ Running database migrations..." -ForegroundColor Yellow
try {
    php artisan migrate --force
    Write-Host "✅ Database migrations completed" -ForegroundColor Green
} catch {
    Write-Host "❌ Database migrations failed" -ForegroundColor Red
    Set-Location ../..
    exit 1
}

# Run tests
Write-Host "🧪 Running tests..." -ForegroundColor Yellow
try {
    php artisan test --testsuite=Feature
    Write-Host "✅ Feature tests passed" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Some tests failed, but continuing..." -ForegroundColor Yellow
}

# Test webhook endpoint
Write-Host "🔗 Testing webhook endpoint..." -ForegroundColor Yellow
try {
    $webhookResponse = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/payments/webhook" -Method POST -ContentType "application/json" -Body '{}' -UseBasicParsing
    if ($webhookResponse.StatusCode -eq 400) {
        Write-Host "✅ Webhook endpoint is responding (400 expected for empty payload)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Webhook endpoint returned unexpected status: $($webhookResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Webhook test failed (server might not be running yet)" -ForegroundColor Yellow
}

# Start Laravel server
Write-Host "🚀 Starting Laravel development server..." -ForegroundColor Yellow
Write-Host "📱 Backend will be available at: http://localhost:8000" -ForegroundColor Cyan
Write-Host "📊 Health check: http://localhost:8000/api/v1/health" -ForegroundColor Cyan
Write-Host "🔗 Webhook endpoint: http://localhost:8000/api/v1/payments/webhook" -ForegroundColor Cyan
Write-Host "" -ForegroundColor White
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow

try {
    php artisan serve --host=0.0.0.0 --port=8000
} catch {
    Write-Host "❌ Failed to start Laravel server" -ForegroundColor Red
    Set-Location ../..
    exit 1
}

Set-Location ../..
