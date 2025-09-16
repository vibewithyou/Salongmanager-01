# Authentication API

## Overview

SalonManager supports two authentication methods:
1. **SPA Flow** - Cookie-based sessions for web applications
2. **PAT Flow** - Personal Access Tokens for mobile/API clients

## SPA Flow (Cookie-based)

### 1. Get CSRF Cookie
```
GET /sanctum/csrf-cookie
```
Sets the XSRF-TOKEN cookie for CSRF protection. Must be called before login.

Alternative endpoint:
```
GET /api/v1/auth/csrf
```

### 2. Login
```
POST /api/v1/auth/login
Headers:
  - X-XSRF-TOKEN: {csrf_token}
  - X-Salon-Slug: {tenant_slug}
  - Content-Type: application/json
  - Accept: application/json

Body:
{
  "email": "user@example.com",
  "password": "password"
}

Response:
200 OK
{
  "ok": true
}

422 Unprocessable Entity
{
  "message": "Invalid credentials"
}
```

### 3. Get Current User
```
GET /api/v1/auth/me
Headers:
  - X-Salon-Slug: {tenant_slug}
  - Cookie: {session_cookie}

Response:
200 OK
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "user@example.com"
  },
  "tenant": {
    "id": 1,
    "slug": "demo",
    "name": "Demo Salon"
  }
}
```

### 4. Logout
```
POST /api/v1/auth/logout
Headers:
  - X-Salon-Slug: {tenant_slug}
  - Cookie: {session_cookie}

Response:
200 OK
{
  "ok": true
}
```

## PAT Flow (Token-based)

### 1. Create Token
```
POST /api/v1/auth/token
Headers:
  - Content-Type: application/json
  - Accept: application/json

Body:
{
  "email": "user@example.com",
  "password": "password",
  "scopes": ["read", "write"]  // optional
}

Response:
200 OK
{
  "token": "1|abcdef123456...",
  "type": "Bearer"
}

422 Unprocessable Entity
{
  "message": "Invalid credentials"
}
```

### 2. Use Token
All subsequent requests must include the token:
```
Headers:
  - Authorization: Bearer {token}
  - X-Salon-Slug: {tenant_slug}
```

### 3. Get Current User
```
GET /api/v1/auth/me
Headers:
  - Authorization: Bearer {token}
  - X-Salon-Slug: {tenant_slug}

Response: Same as SPA flow
```

## Error Responses

### 401 Unauthorized
```json
{
  "message": "Unauthenticated."
}
```

### 422 Unprocessable Entity
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password field is required."]
  }
}
```

### 403 Forbidden (Tenant Mismatch)
```json
{
  "message": "Tenant access denied"
}
```