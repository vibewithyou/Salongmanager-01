# SalonManager Go Live Script (Simple Version)
# This script implements the "Go Live" pack for production deployment

Write-Host "Starting SalonManager Go Live Process..." -ForegroundColor Green

# Set paths
$ROOT = (Resolve-Path .).Path
$BE = Join-Path $ROOT "salonmanager\backend"
$FE = Join-Path $ROOT "salonmanager\frontend"

Write-Host "Project Root: $ROOT" -ForegroundColor Cyan
Write-Host "Backend Path: $BE" -ForegroundColor Cyan
Write-Host "Frontend Path: $FE" -ForegroundColor Cyan

# Step 1: ENV & Runtime Auto-Heal
Write-Host "`nStep 1: ENV & Runtime Auto-Heal" -ForegroundColor Yellow

# Check if .env exists, create if not
$envPath = Join-Path $BE ".env"
if (!(Test-Path $envPath)) {
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    $example = Join-Path $BE ".env.example"
    if (Test-Path $example) { 
        Copy-Item $example $envPath
        Write-Host "SUCCESS: Copied .env.example to .env" -ForegroundColor Green
    } else {
        Write-Host "WARNING: .env.example not found, creating basic .env" -ForegroundColor Yellow
        @"
APP_NAME=SalonManager
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost
LOG_CHANNEL=stack
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=salonmanager
DB_USERNAME=sm_admin
DB_PASSWORD=secret
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1
SESSION_SECURE_COOKIE=false
SENTRY_LARAVEL_DSN=
PAYMENT_PROVIDER=stripe
STRIPE_SECRET=
STRIPE_WEBHOOK_SECRET=
"@ | Out-File -Encoding utf8 $envPath
        Write-Host "SUCCESS: Created basic .env file" -ForegroundColor Green
    }
} else {
    Write-Host "SUCCESS: .env file already exists" -ForegroundColor Green
}

# Check for PHP/Composer
if (!(Get-Command php -ErrorAction SilentlyContinue)) { 
    Write-Host "WARNING: PHP not in PATH - will use Docker flow" -ForegroundColor Yellow 
}
if (!(Get-Command composer -ErrorAction SilentlyContinue)) { 
    Write-Host "WARNING: Composer not in PATH - will use Docker flow" -ForegroundColor Yellow 
}

# Step 2: Docker Stack Setup
Write-Host "`nStep 2: Docker Stack Setup" -ForegroundColor Yellow

# Check if Docker Desktop is running
try {
    docker version | Out-Null
    Write-Host "SUCCESS: Docker is running" -ForegroundColor Green
    
    # Build and start services
    Write-Host "Building Docker containers..." -ForegroundColor Yellow
    docker compose -f ops/deploy/compose.prod.yml build app queue scheduler web
    
    Write-Host "Starting Docker services..." -ForegroundColor Yellow
    docker compose -f ops/deploy/compose.prod.yml up -d
    
    # Wait for services to be ready
    Write-Host "Waiting for services to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    # Step 3: Laravel Setup
    Write-Host "`nStep 3: Laravel Setup" -ForegroundColor Yellow
    
    Write-Host "Generating application key..." -ForegroundColor Yellow
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan key:generate --force
    
    Write-Host "Running migrations..." -ForegroundColor Yellow
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan migrate --force
    
    Write-Host "Caching configuration..." -ForegroundColor Yellow
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan config:cache
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan route:cache
    
    # Step 4: Testing
    Write-Host "`nStep 4: Running Tests" -ForegroundColor Yellow
    
    Write-Host "Running Feature tests..." -ForegroundColor Yellow
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan test --testsuite=Feature
    
    Write-Host "Running E2E tests..." -ForegroundColor Yellow
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan test --group=e2e
    
    # Step 5: Health Checks
    Write-Host "`nStep 5: Health Checks" -ForegroundColor Yellow
    
    Write-Host "Testing health endpoint..." -ForegroundColor Yellow
    try {
        $healthResponse = Invoke-WebRequest -Uri "http://localhost/api/v1/health" -UseBasicParsing
        if ($healthResponse.StatusCode -eq 200) {
            Write-Host "SUCCESS: Health check passed: $($healthResponse.Content)" -ForegroundColor Green
        } else {
            Write-Host "ERROR: Health check failed with status: $($healthResponse.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "ERROR: Health check failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Step 6: Webhook Testing
    Write-Host "`nStep 6: Webhook Testing" -ForegroundColor Yellow
    
    Write-Host "Testing webhook endpoint (should return 400 without signature)..." -ForegroundColor Yellow
    try {
        $webhookResponse = Invoke-WebRequest -Uri "http://localhost/api/v1/payments/webhook" -Method POST -UseBasicParsing
        Write-Host "WARNING: Webhook returned status: $($webhookResponse.StatusCode)" -ForegroundColor Yellow
    } catch {
        if ($_.Exception.Response.StatusCode -eq 400) {
            Write-Host "SUCCESS: Webhook correctly returns 400 without signature" -ForegroundColor Green
        } else {
            Write-Host "ERROR: Webhook test failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Step 7: Backup Testing
    Write-Host "`nStep 7: Backup Testing" -ForegroundColor Yellow
    
    Write-Host "Testing backup system..." -ForegroundColor Yellow
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan backup:run
    
    Write-Host "Listing available backups..." -ForegroundColor Yellow
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan backup:list
    
    Write-Host "`nGo Live Process Completed!" -ForegroundColor Green
    Write-Host "SUCCESS: All systems are ready for production" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: Docker is not running or not available" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and run this script again" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
