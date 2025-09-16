# API Headers

## Required Headers

### Accept Header
All API requests must include:
```
Accept: application/json
```

### Tenant Header
All tenant-scoped endpoints require tenant identification:
```
X-Salon-Slug: {tenant_slug}
```
or
```
X-Salon-ID: {tenant_id}
```

## Authentication Headers

### SPA Flow (Cookie-based)
- **CSRF Token**: `X-XSRF-TOKEN` header for POST/PUT/DELETE requests
- **Session**: Automatically sent via cookies

### PAT Flow (Token-based)
```
Authorization: Bearer {personal_access_token}
```

## Content Type
For requests with body data:
```
Content-Type: application/json
```

## Complete Request Example

### SPA Flow
```http
POST /api/v1/bookings
Headers:
  Accept: application/json
  Content-Type: application/json
  X-Salon-Slug: demo
  X-XSRF-TOKEN: {csrf_token}
  Cookie: {session_cookies}
```

### PAT Flow
```http
POST /api/v1/bookings
Headers:
  Accept: application/json
  Content-Type: application/json
  X-Salon-Slug: demo
  Authorization: Bearer {token}
```

## Optional Headers

### Pagination
```
X-Page: 1
X-Per-Page: 20
```

### Locale
```
Accept-Language: de-DE
```

### API Version (future)
```
X-API-Version: 2024-01-01
```

## Security Headers (Set by Server)

The API automatically sets these security headers in responses:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: SAMEORIGIN`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000` (HTTPS only)