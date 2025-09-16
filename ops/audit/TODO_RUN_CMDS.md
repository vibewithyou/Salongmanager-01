# TODO: Commands to Run for v1.0.0 Release

## Backend Setup Commands

```bash
# Navigate to backend directory
cd salonmanager/backend

# Install dependencies
composer install --no-interaction

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Publish Fortify configuration
php artisan vendor:publish --provider="Laravel\Fortify\FortifyServiceProvider"

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# Run tests
php artisan test --testsuite=Feature
php artisan test --group=e2e

# Test backup system
php artisan backup:run
```

## Frontend Setup Commands

```bash
# Navigate to frontend directory
cd salonmanager/frontend

# Install dependencies
flutter pub get

# Run analysis
flutter analyze

# Run tests
flutter test

# Build for web
flutter build web --release
```

## Environment Configuration

### Required Environment Variables

Add to `.env` file:

```bash
# 2FA Configuration
TWO_FA_REQUIRED_ROLES=owner,platform_admin,salon_owner

# Sentry (Optional - leave empty to disable)
SENTRY_LARAVEL_DSN=
SENTRY_DSN=

# Backup Configuration
BACKUP_DISK=local
BACKUP_NOTIFICATION_MAIL=admin@salonmanager.app
```

## Release Tagging

### Windows (PowerShell)
```powershell
# Make script executable and run
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\ops\release\tag.ps1 --version v1.0.0
```

### Unix/Linux (Bash)
```bash
# Make script executable and run
chmod +x ops/release/tag.sh
./ops/release/tag.sh --version v1.0.0
```

## Health Checks

```bash
# Test health endpoint
curl -sSf http://localhost:8000/api/v1/health

# Test backup system
php artisan backup:list

# Test 2FA endpoints (requires authentication)
curl -X POST http://localhost:8000/api/v1/auth/2fa/enable \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

## Security Verification

```bash
# Check security headers
curl -I http://localhost:8000/api/v1/health

# Verify CORS headers
curl -H "Origin: https://salongmanager.app" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: X-Requested-With" \
  -X OPTIONS http://localhost:8000/api/v1/auth/login
```

## Database Verification

```sql
-- Check 2FA fields exist
DESCRIBE users;

-- Check gallery tables exist
SHOW TABLES LIKE 'gallery_%';

-- Verify indexes
SHOW INDEX FROM gallery_photos;
SHOW INDEX FROM gallery_albums;
SHOW INDEX FROM gallery_consents;
```

## Deployment Commands

```bash
# Docker deployment
docker-compose -f docker-compose.prod.yml up -d

# Or systemd deployment
sudo systemctl start salonmanager-backend
sudo systemctl start salonmanager-frontend

# Verify services
sudo systemctl status salonmanager-backend
sudo systemctl status salonmanager-frontend
```

## Post-Deployment Verification

```bash
# Check application logs
docker-compose -f docker-compose.prod.yml logs -f

# Or systemd logs
sudo journalctl -u salonmanager-backend -f
sudo journalctl -u salonmanager-frontend -f

# Test all endpoints
curl http://localhost:8000/api/v1/health
curl http://localhost:8000/api/v1/search/salons
curl http://localhost:8000/api/v1/gallery/albums
```

## Monitoring Setup

```bash
# Check Sentry integration (if configured)
# Look for events in Sentry dashboard

# Check backup monitoring
php artisan backup:monitor

# Check queue workers
php artisan queue:work --once
```

## Rollback Commands (if needed)

```bash
# Activate maintenance mode
php artisan down --message="Emergency maintenance in progress"

# Restore from backup
php artisan backup:restore --disk=local --backup=latest

# Revert to previous tag
git checkout v0.9.0
git push origin v0.9.0

# Restart services
docker-compose -f docker-compose.prod.yml restart
# or
sudo systemctl restart salonmanager-backend
sudo systemctl restart salonmanager-frontend

# Disable maintenance mode
php artisan up
```

---

**Note:** All commands should be run in the appropriate environment (development, staging, production) with proper permissions and configuration.
