# Customer Management API

## Overview

This API provides comprehensive customer management functionality including profiles, notes, media, loyalty programs, and discounts.

## Endpoints

### Customer Directory

#### GET /api/v1/customers
List all customers with pagination and search.

**Query Parameters:**
- `search` (optional): Search by name or email
- `page` (optional): Page number for pagination

**Response:**
```json
{
  "customers": {
    "data": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
      }
    ],
    "next_page_url": "http://api.example.com/api/v1/customers?page=2"
  }
}
```

**Authorization:** Requires `salon_owner`, `salon_manager`, or `stylist` role.

#### GET /api/v1/customers/{customer}
Get customer details and profile.

**Response:**
```json
{
  "customer": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  },
  "profile": {
    "id": 1,
    "phone": "+1234567890",
    "preferred_stylist": "Jane Smith",
    "prefs": {
      "allergies": ["hair dye"],
      "hair_type": "curly"
    },
    "address": {
      "street": "123 Main St",
      "city": "New York",
      "zip": "10001",
      "country": "US"
    }
  }
}
```

**Authorization:** Requires `salon_owner`, `salon_manager`, `stylist`, or `customer` role (customers can only view their own data).

#### PUT /api/v1/customers/{customer}
Update customer profile.

**Request Body:**
```json
{
  "phone": "+1234567890",
  "preferred_stylist": "Jane Smith",
  "prefs": {
    "allergies": ["hair dye"],
    "hair_type": "curly"
  },
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "zip": "10001",
    "country": "US"
  }
}
```

**Authorization:** Requires `salon_owner`, `salon_manager`, or `customer` role (customers can only update their own data).

### Customer Notes

#### GET /api/v1/customers/{customer}/notes
Get all notes for a customer.

**Response:**
```json
{
  "notes": [
    {
      "id": 1,
      "customer_id": 1,
      "author_id": 2,
      "note": "Customer prefers morning appointments",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

**Authorization:** Requires `salon_owner`, `salon_manager`, or `stylist` role.

#### POST /api/v1/customers/notes
Create a new note for a customer.

**Request Body:**
```json
{
  "customer_id": 1,
  "note": "Customer prefers morning appointments"
}
```

**Authorization:** Requires `salon_owner`, `salon_manager`, or `stylist` role.

#### PUT /api/v1/customers/notes/{note}
Update an existing note.

**Request Body:**
```json
{
  "note": "Updated note content"
}
```

**Authorization:** Requires `salon_owner`, `salon_manager` role, or the note author (for stylists).

#### DELETE /api/v1/customers/notes/{note}
Delete a note.

**Authorization:** Requires `salon_owner`, `salon_manager` role, or the note author (for stylists).

### Loyalty Program

#### GET /api/v1/customers/{customer}/loyalty
Get customer's loyalty card and transaction history.

**Response:**
```json
{
  "card": {
    "id": 1,
    "points": 150,
    "meta": {
      "tier": "gold",
      "expires_at": "2024-12-31"
    }
  },
  "transactions": [
    {
      "id": 1,
      "delta": 50,
      "reason": "Service completed",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

**Authorization:** Requires `salon_owner`, `salon_manager`, `stylist`, or `customer` role (customers can only view their own data).

#### POST /api/v1/customers/{customer}/loyalty/adjust
Adjust customer's loyalty points.

**Request Body:**
```json
{
  "delta": 50,
  "reason": "Service completed"
}
```

**Authorization:** Requires `salon_owner`, `salon_manager`, or `stylist` role.

### Discounts

#### GET /api/v1/discounts
Get all active discounts.

**Response:**
```json
{
  "discounts": [
    {
      "id": 1,
      "code": "WELCOME10",
      "type": "percent",
      "value": 10.00,
      "valid_from": "2024-01-01",
      "valid_to": "2024-12-31",
      "active": true,
      "conditions": {
        "min_amount": 50.00,
        "customer_tier": "new"
      }
    }
  ]
}
```

**Authorization:** Public endpoint (no authentication required).

## GDPR Compliance

### Export Request
#### POST /api/v1/customers/{customer}/request-export
Request a data export for a customer.

**Authorization:** Requires `salon_owner`, `salon_manager`, or `customer` role (customers can only request their own data).

**Response:**
```json
{
  "ok": true,
  "message": "Export requested (TODO job)"
}
```

### Deletion Request
#### POST /api/v1/customers/{customer}/request-deletion
Request data deletion for a customer.

**Authorization:** Requires `salon_owner`, `salon_manager`, or `customer` role (customers can only request their own data).

**Response:**
```json
{
  "ok": true,
  "message": "Deletion requested (TODO workflow)"
}
```

## Error Responses

All endpoints return standard HTTP status codes and error responses:

```json
{
  "message": "Error description",
  "errors": {
    "field": ["Validation error message"]
  }
}
```

## Rate Limiting

API endpoints are subject to rate limiting. Please refer to the main API documentation for current limits.

## Data Models

### Customer Profile
- `phone`: Customer's phone number (optional)
- `preferred_stylist`: Name of preferred stylist (optional)
- `prefs`: JSON object for preferences (allergies, hair type, etc.)
- `address`: JSON object for address information

### Customer Note
- `customer_id`: ID of the customer
- `author_id`: ID of the staff member who created the note
- `note`: Note content (max 2000 characters)

### Loyalty Card
- `points`: Current point balance
- `meta`: JSON object for additional metadata (tier, expiration, etc.)

### Loyalty Transaction
- `delta`: Point change (+ for earned, - for redeemed)
- `reason`: Description of the transaction
- `meta`: Additional transaction metadata

### Discount
- `code`: Unique discount code
- `type`: "percent" or "fixed"
- `value`: Discount value (percentage or fixed amount)
- `valid_from`/`valid_to`: Validity period
- `active`: Whether the discount is currently active
- `conditions`: JSON object for usage conditions