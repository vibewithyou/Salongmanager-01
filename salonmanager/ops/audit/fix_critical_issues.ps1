# Fix Critical Production Issues Script
# This script addresses the most critical issues found in the audit

Write-Host "=== Fixing Critical Production Issues ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
Write-Host ""

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$backend = Join-Path $root "salonmanager\backend"
$frontend = Join-Path $root "frontend"

# 1. Register TenantRequired middleware in Kernel.php
Write-Host "1. Registering TenantRequired middleware..." -ForegroundColor Yellow
$kernelFile = Join-Path $backend "app\Http\Kernel.php"
if (Test-Path $kernelFile) {
    $kernelContent = Get-Content $kernelFile -Raw
    
    # Check if TenantRequired is already registered
    if ($kernelContent -notmatch "TenantRequired") {
        # Add to routeMiddleware array
        $kernelContent = $kernelContent -replace '(\s+)(protected \$routeMiddleware = \[)', "`$1`$2`n`$1    'tenant.required' => \App\Http\Middleware\TenantRequired::class,"
        
        # Add to aliases
        $kernelContent = $kernelContent -replace '(\s+)(protected \$middlewareAliases = \[)', "`$1`$2`n`$1    'tenant.required' => \App\Http\Middleware\TenantRequired::class,"
        
        Set-Content -Path $kernelFile -Value $kernelContent -Encoding UTF8
        Write-Host "   ✓ TenantRequired middleware registered" -ForegroundColor Green
    } else {
        Write-Host "   ✓ TenantRequired middleware already registered" -ForegroundColor Green
    }
} else {
    Write-Host "   ✗ Kernel.php not found" -ForegroundColor Red
}

# 2. Create missing PWA icons (placeholder)
Write-Host "`n2. Creating PWA icons..." -ForegroundColor Yellow
$iconsDir = Join-Path $frontend "web\icons"
if (!(Test-Path $iconsDir)) {
    New-Item -ItemType Directory -Path $iconsDir -Force | Out-Null
}

# Create placeholder icon files (1x1 pixel PNG)
$iconData = [Convert]::FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")

$iconFiles = @("icon-192.png", "icon-512.png", "icon-maskable.png")
foreach ($iconFile in $iconFiles) {
    $iconPath = Join-Path $iconsDir $iconFile
    if (!(Test-Path $iconPath)) {
        [System.IO.File]::WriteAllBytes($iconPath, $iconData)
        Write-Host "   ✓ Created $iconFile (placeholder)" -ForegroundColor Green
    } else {
        Write-Host "   ✓ $iconFile already exists" -ForegroundColor Green
    }
}

# 3. Create basic nginx configuration
Write-Host "`n3. Creating nginx configuration..." -ForegroundColor Yellow
$nginxDir = Join-Path $root "nginx"
if (!(Test-Path $nginxDir)) {
    New-Item -ItemType Directory -Path $nginxDir -Force | Out-Null
}

$nginxConfig = @"
events {
    worker_connections 1024;
}

http {
    upstream app {
        server app:9000;
    }

    server {
        listen 80;
        server_name localhost;
        root /var/www/html/public;
        index index.php;

        location / {
            try_files `$uri `$uri/ /index.php?`$query_string;
        }

        location ~ \.php$ {
            fastcgi_pass app;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME `$document_root`$fastcgi_script_name;
            include fastcgi_params;
        }

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    }
}
"@

$nginxConfigFile = Join-Path $nginxDir "nginx.conf"
if (!(Test-Path $nginxConfigFile)) {
    Set-Content -Path $nginxConfigFile -Value $nginxConfig -Encoding UTF8
    Write-Host "   ✓ Created nginx.conf" -ForegroundColor Green
} else {
    Write-Host "   ✓ nginx.conf already exists" -ForegroundColor Green
}

# 4. Create MySQL initialization script
Write-Host "`n4. Creating MySQL initialization script..." -ForegroundColor Yellow
$mysqlDir = Join-Path $root "mysql\init"
if (!(Test-Path $mysqlDir)) {
    New-Item -ItemType Directory -Path $mysqlDir -Force | Out-Null
}

$mysqlInit = @"
-- Create database if not exists
CREATE DATABASE IF NOT EXISTS salonmanager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user if not exists
CREATE USER IF NOT EXISTS 'salonmanager'@'%' IDENTIFIED BY 'salonmanager_password';
GRANT ALL PRIVILEGES ON salonmanager.* TO 'salonmanager'@'%';
FLUSH PRIVILEGES;

-- Set timezone
SET time_zone = '+00:00';
"@

$mysqlInitFile = Join-Path $mysqlDir "01-init.sql"
if (!(Test-Path $mysqlInitFile)) {
    Set-Content -Path $mysqlInitFile -Value $mysqlInit -Encoding UTF8
    Write-Host "   ✓ Created MySQL initialization script" -ForegroundColor Green
} else {
    Write-Host "   ✓ MySQL initialization script already exists" -ForegroundColor Green
}

# 5. Create Flutter Dockerfile
Write-Host "`n5. Creating Flutter Dockerfile..." -ForegroundColor Yellow
$flutterDockerfile = @"
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:`$PATH"

# Enable Flutter web
RUN flutter config --enable-web

WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Build web
RUN flutter build web --release

# Expose port
EXPOSE 3000

# Serve the app
CMD ["flutter", "run", "-d", "web-server", "--web-port", "3000", "--web-hostname", "0.0.0.0"]
"@

$flutterDockerfilePath = Join-Path $frontend "Dockerfile"
if (!(Test-Path $flutterDockerfilePath)) {
    Set-Content -Path $flutterDockerfilePath -Value $flutterDockerfile -Encoding UTF8
    Write-Host "   ✓ Created Flutter Dockerfile" -ForegroundColor Green
} else {
    Write-Host "   ✓ Flutter Dockerfile already exists" -ForegroundColor Green
}

# 6. Create production-ready docker-compose
Write-Host "`n6. Creating production docker-compose..." -ForegroundColor Yellow
$prodCompose = @"
version: '3.8'

services:
  app:
    build:
      context: ./salonmanager/backend
      dockerfile: Dockerfile
    container_name: salonmanager_app_prod
    restart: unless-stopped
    working_dir: /var/www/html
    volumes:
      - ./salonmanager/backend:/var/www/html
      - ./salonmanager/backend/storage:/var/www/html/storage
    networks:
      - salonmanager_network
    depends_on:
      - db
      - redis
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
      - DB_CONNECTION=mysql
      - DB_HOST=db
      - DB_PORT=3306
      - DB_DATABASE=salonmanager
      - DB_USERNAME=salonmanager
      - DB_PASSWORD=salonmanager_password
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - QUEUE_CONNECTION=redis

  web:
    image: nginx:alpine
    container_name: salonmanager_web_prod
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./salonmanager/backend/public:/var/www/html/public
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    networks:
      - salonmanager_network
    depends_on:
      - app

  db:
    image: mysql:8.0
    container_name: salonmanager_db_prod
    restart: unless-stopped
    ports:
      - "3306:3306"
    volumes:
      - mysql_data_prod:/var/lib/mysql
      - ./mysql/init:/docker-entrypoint-initdb.d
    environment:
      - MYSQL_ROOT_PASSWORD=root_password
      - MYSQL_DATABASE=salonmanager
      - MYSQL_USER=salonmanager
      - MYSQL_PASSWORD=salonmanager_password
    networks:
      - salonmanager_network

  redis:
    image: redis:7-alpine
    container_name: salonmanager_redis_prod
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data_prod:/data
    networks:
      - salonmanager_network

  queue:
    build:
      context: ./salonmanager/backend
      dockerfile: Dockerfile
    container_name: salonmanager_queue_prod
    restart: unless-stopped
    working_dir: /var/www/html
    volumes:
      - ./salonmanager/backend:/var/www/html
      - ./salonmanager/backend/storage:/var/www/html/storage
    networks:
      - salonmanager_network
    depends_on:
      - db
      - redis
    command: php artisan queue:work --verbose --tries=3 --timeout=90
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
      - DB_CONNECTION=mysql
      - DB_HOST=db
      - DB_PORT=3306
      - DB_DATABASE=salonmanager
      - DB_USERNAME=salonmanager
      - DB_PASSWORD=salonmanager_password
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - QUEUE_CONNECTION=redis

  scheduler:
    build:
      context: ./salonmanager/backend
      dockerfile: Dockerfile
    container_name: salonmanager_scheduler_prod
    restart: unless-stopped
    working_dir: /var/www/html
    volumes:
      - ./salonmanager/backend:/var/www/html
      - ./salonmanager/backend/storage:/var/www/html/storage
    networks:
      - salonmanager_network
    depends_on:
      - db
      - redis
    command: php artisan schedule:work
    environment:
      - APP_ENV=production
      - APP_DEBUG=false
      - DB_CONNECTION=mysql
      - DB_HOST=db
      - DB_PORT=3306
      - DB_DATABASE=salonmanager
      - DB_USERNAME=salonmanager
      - DB_PASSWORD=salonmanager_password
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - QUEUE_CONNECTION=redis

volumes:
  mysql_data_prod:
    driver: local
  redis_data_prod:
    driver: local

networks:
  salonmanager_network:
    driver: bridge
"@

$prodComposeFile = Join-Path $root "docker-compose.prod.yml"
if (!(Test-Path $prodComposeFile)) {
    Set-Content -Path $prodComposeFile -Value $prodCompose -Encoding UTF8
    Write-Host "   ✓ Created production docker-compose.yml" -ForegroundColor Green
} else {
    Write-Host "   ✓ Production docker-compose.yml already exists" -ForegroundColor Green
}

# 7. Create deployment script
Write-Host "`n7. Creating deployment script..." -ForegroundColor Yellow
$deployScript = @"
#!/bin/bash
set -e

echo "=== Deploying SalonManager ==="

# Pull latest changes
git pull origin main

# Build and start services
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

# Run migrations
docker-compose -f docker-compose.prod.yml exec app php artisan migrate --force

# Clear caches
docker-compose -f docker-compose.prod.yml exec app php artisan config:cache
docker-compose -f docker-compose.prod.yml exec app php artisan route:cache
docker-compose -f docker-compose.prod.yml exec app php artisan view:cache

echo "=== Deployment Complete ==="
"@

$deployScriptFile = Join-Path $root "deploy.sh"
if (!(Test-Path $deployScriptFile)) {
    Set-Content -Path $deployScriptFile -Value $deployScript -Encoding UTF8
    Write-Host "   ✓ Created deployment script" -ForegroundColor Green
} else {
    Write-Host "   ✓ Deployment script already exists" -ForegroundColor Green
}

Write-Host "`n=== Critical Issues Fix Complete ===" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Copy .env.example to salonmanager/backend/.env and configure" -ForegroundColor White
Write-Host "2. Run: docker-compose up -d" -ForegroundColor White
Write-Host "3. Run: docker-compose exec app php artisan migrate" -ForegroundColor White
Write-Host "4. Run: docker-compose exec app php artisan key:generate" -ForegroundColor White
Write-Host "5. Test the application at http://localhost" -ForegroundColor White
