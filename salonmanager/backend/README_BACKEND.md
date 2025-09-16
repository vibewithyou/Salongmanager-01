# SalonManager Backend

Backend API für das SalonManager-System.

## Übersicht

- **Framework**: Laravel 12
- **API**: RESTful JSON API v1
- **Auth**: Laravel Sanctum (SPA + PAT)
- **DB**: MySQL/PostgreSQL
- **Queue**: Redis/Database
- **Multi-Tenancy**: Subdomain/Header-based tenant resolution

## Module

- `/Modules/Auth` - Authentifizierung & Autorisierung
- `/Modules/Salon` - Salon-Verwaltung
- `/Modules/Staff` - Mitarbeiterverwaltung
- `/Modules/Customer` - Kundenverwaltung
- `/Modules/Booking` - Terminbuchung
- `/Modules/Billing_POS` - Kasse & Abrechnung
- `/Modules/Inventory` - Lagerverwaltung
- `/Modules/Reports` - Berichte & Analysen
- `/Modules/RBAC` - Rollen & Berechtigungen
- `/Modules/Search_Map` - Suche & Kartenintegration
- `/Modules/Gallery_KI` - Galerie & KI-Features
- `/Modules/Loyalty` - Treueprogramm

## Setup

### Development Setup

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed  # TODO: Create seeders
php artisan serve
```

### Run Tests

```bash
php artisan test
# or with Pest
./vendor/bin/pest
```

### Static Analysis

```bash
./vendor/bin/phpstan analyse
```

## Authentication Flows

### SPA Authentication (Cookie-based)

1. **Login**: `POST /api/v1/auth/login`
   ```json
   {
     "email": "user@example.com",
     "password": "password"
   }
   ```
   Returns session cookie for subsequent requests.

2. **Logout**: `POST /api/v1/auth/logout`

3. **Get Current User**: `GET /api/v1/auth/me`

### Personal Access Token (PAT) for Mobile/API

1. **Get Token**: `POST /api/v1/auth/token`
   ```json
   {
     "email": "user@example.com",
     "password": "password",
     "scopes": ["read", "write"]  // optional
   }
   ```
   Returns:
   ```json
   {
     "token": "1|abcdef123456...",
     "type": "Bearer"
   }
   ```

2. **Use Token**: Include in Authorization header
   ```
   Authorization: Bearer 1|abcdef123456...
   ```

## Tenant Resolution

The system supports multi-tenancy through subdomain or header-based tenant resolution:

### Subdomain-based

Access salon via subdomain: `https://mysalon.salongmanager.app`

### Header-based

Include one of these headers in your request:
- `X-Salon-ID: 123` (by ID)
- `X-Salon-Slug: my-salon` (by slug)

If no tenant can be resolved, the API returns a 400 error:
```json
{
  "error": "TENANT_NOT_RESOLVED"
}
```

## Rate Limiting

Current rate limits:
- **General API**: 60 requests/minute per IP
- **Authenticated API**: 120 requests/minute per user

TODO: Fine-grained rate limits by role/scope (Slice 3)

## CORS Configuration

Allowed origins:
- `https://salongmanager.app`
- `https://*.salongmanager.app`
- `http://localhost:3000`
- `http://127.0.0.1:3000`

Credentials are supported for cookie-based authentication.

## API Endpoints

### Health Check
- `GET /api/v1/health` - System health check

### Authentication
- `POST /api/v1/auth/login` - SPA login (cookie)
- `POST /api/v1/auth/logout` - SPA logout
- `POST /api/v1/auth/token` - Get PAT
- `GET /api/v1/auth/me` - Get current user info

## Audit Logging

All significant actions are logged in the `audit_logs` table with:
- User ID
- Salon ID
- Action name
- IP address
- User agent
- Additional metadata (JSON)

## Environment Variables

Key environment variables:

```env
# Application
APP_NAME=SalonManager
APP_ENV=local
APP_DEBUG=true
APP_URL=https://salongmanager.app

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=salonmanager
DB_USERNAME=sm_admin
DB_PASSWORD=securepassword

# Sanctum
SANCTUM_STATEFUL_DOMAINS=salongmanager.app,.salongmanager.app,localhost,127.0.0.1,localhost:3000,127.0.0.1:3000
SESSION_DOMAIN=.salongmanager.app
```

## Database Schema

### Core Tables
- `users` - User accounts with current_salon_id
- `salons` - Tenant/salon information
- `audit_logs` - Action logging for compliance

### Migrations Plan (TODO)
1. tenants (Mandanten/Salons) – Basis-Stammdaten, Settings, Themes
2. users – Basis, Mandanten-Bezug, Verifizierungen
3. roles, permissions, role_user, permission_role – RBAC-Grundlage
4. audit_logs – entity, actor, action, metadata
5. staff – Profile, Skills, Arbeitszeiten
6. services & pricing – buchbare Leistungen
7. bookings – Termine, Status, Regeln
8. customers – Profile, Präferenzen, DSGVO-Flags
9. loyalty – Punkte, Rewards, Transaktionen
10. inventory – Artikel, Bestände, Bewegungen
11. billing & pos – Rechnungen, Zahlungen, Kassenbelege
12. media/gallery – Medien, KI-Pipelines

## API Documentation

API documentation is available at `/docs/api` or after starting the server at `http://localhost:8000/api/documentation` (TODO: Implement OpenAPI/Swagger documentation)