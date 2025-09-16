# TODO: Run Commands for Feature Completion Pack

## Backend Setup

```bash
# Navigate to backend directory
cd salonmanager/backend

# Run migrations
php artisan migrate

# Run new feature tests
php artisan test --testsuite=Feature --group=gallery
php artisan test --testsuite=Feature --group=booking_from_photo
php artisan test --testsuite=Feature --group=ai

# Run all tests to ensure nothing is broken
php artisan test
```

## Frontend Setup

```bash
# Navigate to frontend directory
cd salonmanager/frontend

# Install dependencies
flutter pub get

# Run analysis
flutter analyze

# Run tests
flutter test

# Run specific gallery tests
flutter test test/features/gallery_ai/
```

## Environment Configuration

Add to `.env`:
```env
# AI Recommender Configuration
AI_RECOMMENDER=null
```

## Verification Commands

```bash
# Check if all new routes are registered
cd salonmanager/backend
php artisan route:list --path=gallery
php artisan route:list --path=customers
php artisan route:list --path=bookings

# Verify migrations
php artisan migrate:status

# Check for any linting errors
cd salonmanager/backend
./vendor/bin/pint --test

cd salonmanager/frontend
flutter analyze
```

## Database Verification

```sql
-- Check if new tables exist
SHOW TABLES LIKE 'gallery_%';

-- Check if customer_id column exists in gallery_photos
DESCRIBE gallery_photos;

-- Check if visibility enum was updated
SHOW COLUMNS FROM gallery_albums LIKE 'visibility';
```

## API Testing

```bash
# Test gallery endpoints (requires running server)
curl -X GET "http://localhost:8000/api/v1/gallery/photos" \
  -H "Accept: application/json"

# Test photo stats (public endpoint)
curl -X GET "http://localhost:8000/api/v1/gallery/photos/1/stats" \
  -H "Accept: application/json"

# Test AI suggestions (public endpoint)
curl -X GET "http://localhost:8000/api/v1/gallery/photos/1/suggested-services" \
  -H "Accept: application/json"
```

## Feature Verification Checklist

- [ ] Gallery likes and favorites work
- [ ] Customer galleries are accessible with proper RBAC
- [ ] Booking from photo creates draft bookings
- [ ] AI stubs return empty arrays with disabled header
- [ ] All tests pass
- [ ] No linting errors
- [ ] OpenAPI documentation is updated
- [ ] Migrations are reversible