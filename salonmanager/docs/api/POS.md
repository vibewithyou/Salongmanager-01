# POS & Billing API Documentation

## Overview

The POS (Point of Sale) system provides comprehensive billing functionality with GoBD-compliant invoice numbering, tax calculations, payment processing, and reporting capabilities.

## Features

- **GoBD-compliant invoice numbering**: Sequential numbering per salon/year (Format: `2025-SALON-000001`)
- **Tax calculations**: Support for multiple tax rates with automatic breakdown
- **Payment processing**: Cash, card, and external payment methods
- **Refund management**: Full and partial refunds with line-item support
- **Session management**: POS session tracking with opening/closing cash
- **Reporting**: Z-reports and DATEV CSV export

## RBAC (Role-Based Access Control)

### POS Usage
- **salon_owner**: Full access to all POS features
- **salon_manager**: Full access to all POS features
- **stylist**: Can create invoices and process payments, cannot refund or access reports

### POS Management
- **salon_owner**: Can close sessions, process refunds, access reports
- **salon_manager**: Can close sessions, process refunds, access reports

## API Endpoints

### Sessions

#### Open Session
```
POST /api/v1/pos/sessions/open
```

**Request Body:**
```json
{
  "opening_cash": 50.00
}
```

**Response:**
```json
{
  "session": {
    "id": 1,
    "salon_id": 1,
    "user_id": 1,
    "opened_at": "2025-01-15T10:00:00Z",
    "opening_cash": 50.00,
    "closing_cash": null,
    "meta": null
  }
}
```

#### Close Session
```
POST /api/v1/pos/sessions/{session}/close
```

**Request Body:**
```json
{
  "closing_cash": 150.00
}
```

### Invoices

#### Create Invoice
```
POST /api/v1/pos/invoices
```

**Request Body:**
```json
{
  "customer_id": 123,
  "lines": [
    {
      "type": "service",
      "reference_id": 1,
      "name": "Haarschnitt",
      "qty": 1,
      "unit_net": 30.00,
      "tax_rate": 19.00,
      "discount": {"percent": 10}
    },
    {
      "type": "product",
      "reference_id": 101,
      "name": "Shampoo 250ml",
      "qty": 2,
      "unit_net": 10.00,
      "tax_rate": 19.00
    }
  ],
  "meta": {
    "notes": "Customer request"
  }
}
```

**Response:**
```json
{
  "invoice": {
    "id": 1,
    "number": "2025-SALON-000001",
    "issued_at": "2025-01-15T10:30:00Z",
    "total_net": 54.00,
    "total_tax": 10.26,
    "total_gross": 64.26,
    "status": "open",
    "items": [...]
  }
}
```

#### Get Invoice
```
GET /api/v1/pos/invoices/{invoice}
```

### Payments

#### Process Payment
```
POST /api/v1/pos/invoices/{invoice}/pay
```

**Request Body:**
```json
{
  "method": "cash",
  "amount": 64.26,
  "meta": {}
}
```

**Payment Methods:**
- `cash`: Cash payment
- `card`: Card payment (stub)
- `external`: External payment provider (stub)

### Refunds

#### Process Refund
```
POST /api/v1/pos/invoices/{invoice}/refund
```

**Request Body:**
```json
{
  "amount": 32.13,
  "reason": "Customer complaint",
  "lines": [
    {
      "item_id": 1,
      "qty": 1,
      "amount": 32.13
    }
  ]
}
```

### Reports

#### Z-Report
```
GET /api/v1/pos/reports/z?from=2025-01-15&to=2025-01-15
```

**Response:**
```json
{
  "range": ["2025-01-15 00:00:00", "2025-01-15 23:59:59"],
  "summary": {
    "net": 540.00,
    "tax": 102.60,
    "gross": 642.60
  },
  "payments": {
    "cash": 400.00,
    "card": 242.60
  },
  "count_invoices": 12
}
```

#### DATEV Export
```
GET /api/v1/pos/exports/datev.csv?from=2025-01-01&to=2025-01-31
```

Returns CSV file with invoice data for accounting import.

## Invoice Numbering

The system generates GoBD-compliant sequential invoice numbers:

- **Format**: `{YEAR}-{SALON_SLUG}-{SEQUENCE}`
- **Example**: `2025-SALON-000001`
- **Uniqueness**: Guaranteed per salon per year
- **Transaction Safety**: Uses database transactions with row locking

## Tax Calculations

### Tax Breakdown
The system automatically calculates tax breakdowns by rate:

```json
{
  "tax_breakdown": [
    {
      "rate": 19.00,
      "net": 100.00,
      "tax": 19.00
    },
    {
      "rate": 7.00,
      "net": 50.00,
      "tax": 3.50
    }
  ]
}
```

### Discounts
Support for percentage and fixed amount discounts:

```json
{
  "discount": {"percent": 10}  // 10% discount
}
```

```json
{
  "discount": 5.00  // €5.00 discount
}
```

## Status Flow

1. **open**: Invoice created, not yet paid
2. **paid**: Invoice fully paid
3. **refunded**: Invoice fully refunded
4. **canceled**: Invoice canceled (not implemented)

## Error Handling

All endpoints return standard HTTP status codes:

- `200`: Success
- `201`: Created
- `400`: Validation error
- `403`: Insufficient permissions
- `404`: Resource not found
- `422`: Unprocessable entity

Error responses include detailed validation messages:

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "lines.0.name": ["The name field is required."]
  }
}
```