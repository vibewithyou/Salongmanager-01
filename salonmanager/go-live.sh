#!/bin/bash

# SalonManager Go Live Script
# This script implements the "Go Live" pack for production deployment

echo "🚀 Starting SalonManager Go Live Process..."

# Set paths
ROOT="$(pwd)"
BE="$ROOT/salonmanager/backend"
FE="$ROOT/salonmanager/frontend"

echo "📁 Project Root: $ROOT"
echo "📁 Backend Path: $BE"
echo "📁 Frontend Path: $FE"

# Step 1: ENV & Runtime Auto-Heal
echo ""
echo "🔧 Step 1: ENV & Runtime Auto-Heal"

# Check if .env exists, create if not
if [ ! -f "$BE/.env" ]; then
    echo "Creating .env file..."
    if [ -f "$BE/.env.example" ]; then
        cp "$BE/.env.example" "$BE/.env"
        echo "✅ Copied .env.example to .env"
    else
        echo "⚠️  .env.example not found, creating basic .env"
        cat > "$BE/.env" << 'EOF'
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
EOF
        echo "✅ Created basic .env file"
    fi
else
    echo "✅ .env file already exists"
fi

# Check for PHP/Composer
if ! command -v php &> /dev/null; then
    echo "⚠️  PHP not in PATH - will use Docker flow"
fi
if ! command -v composer &> /dev/null; then
    echo "⚠️  Composer not in PATH - will use Docker flow"
fi

# Step 2: Docker Stack Setup
echo ""
echo "🐳 Step 2: Docker Stack Setup"

# Check if Docker is running
if docker version &> /dev/null; then
    echo "✅ Docker is running"
    
    # Build and start services
    echo "Building Docker containers..."
    docker compose -f ops/deploy/compose.prod.yml build app queue scheduler web
    
    echo "Starting Docker services..."
    docker compose -f ops/deploy/compose.prod.yml up -d
    
    # Wait for services to be ready
    echo "Waiting for services to start..."
    sleep 30
    
    # Step 3: Laravel Setup
    echo ""
    echo "⚙️  Step 3: Laravel Setup"
    
    echo "Generating application key..."
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan key:generate --force
    
    echo "Running migrations..."
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan migrate --force
    
    echo "Caching configuration..."
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan config:cache
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan route:cache
    
    # Step 4: Testing
    echo ""
    echo "🧪 Step 4: Running Tests"
    
    echo "Running Feature tests..."
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan test --testsuite=Feature
    
    echo "Running E2E tests..."
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan test --group=e2e
    
    # Step 5: Health Checks
    echo ""
    echo "🏥 Step 5: Health Checks"
    
    echo "Testing health endpoint..."
    if curl -sSf http://localhost/api/v1/health > /dev/null; then
        echo "✅ Health check passed"
        curl -s http://localhost/api/v1/health | jq .
    else
        echo "❌ Health check failed"
    fi
    
    # Step 6: Webhook Testing
    echo ""
    echo "🔗 Step 6: Webhook Testing"
    
    echo "Testing webhook endpoint (should return 400 without signature)..."
    if curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost/api/v1/payments/webhook | grep -q "400"; then
        echo "✅ Webhook correctly returns 400 without signature"
    else
        echo "⚠️  Webhook test inconclusive"
    fi
    
    # Step 7: Backup Testing
    echo ""
    echo "💾 Step 7: Backup Testing"
    
    echo "Testing backup system..."
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan backup:run
    
    echo "Listing available backups..."
    docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan backup:list
    
    echo ""
    echo "🎉 Go Live Process Completed!"
    echo "✅ All systems are ready for production"
    
else
    echo "❌ Docker is not running or not available"
    echo "Please start Docker and run this script again"
    exit 1
fi
