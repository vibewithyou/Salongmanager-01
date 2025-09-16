# Payment System Implementation

## Overview

This implementation provides a comprehensive payment system for the SalonManager application with support for Stripe and Mollie payment providers, including webhooks, refunds, and DATEV export functionality.

## Features

- **Multi-Provider Support**: Stripe and Mollie adapters with easy switching
- **Payment Processing**: Create payment sessions for invoices
- **Webhook Handling**: Automatic payment status updates via webhooks
- **Refunds**: Full and partial refunds through payment providers
- **DATEV Export**: GoBD-compliant accounting export
- **POS Integration**: Enhanced POS controller for payment operations

## Configuration

Add the following environment variables to your `.env` file:

```env
# Payment Provider Configuration
PAYMENT_PROVIDER=stripe  # or 'mollie'

# Stripe Configuration
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_stripe_webhook_secret_here

# Mollie Configuration
MOLLIE_API_KEY=test_your_mollie_api_key_here
MOLLIE_WEBHOOK_URL=https://your-domain.com/api/v1/payments/webhook
```

## API Endpoints

### Payment Operations

- `POST /api/v1/pos/invoices/{invoice}/charge` - Create payment session
- `POST /api/v1/pos/invoices/{invoice}/refund-payment` - Process refund
- `GET /api/v1/pos/invoices/{invoice}/payment-status` - Get payment status
- `GET /api/v1/pos/invoices/open` - Get open invoices for POS

### Webhooks

- `POST /api/v1/payments/webhook` - Payment provider webhooks

## Usage Examples

### Creating a Payment Session

```php
$posController = new PosController($paymentService);
$response = $posController->charge($request, $invoice);
```

### Processing a Refund

```php
$response = $posController->refund($request, $invoice);
```

### DATEV Export

```bash
php artisan export:datev 2024-01-01 2024-01-31
```

## Flutter Integration

The Flutter POS repository provides methods for:

- `chargeInvoice()` - Create payment sessions
- `refundInvoice()` - Process refunds
- `getPaymentStatus()` - Check payment status
- `getOpenInvoices()` - List open invoices

## Security Considerations

- All payment provider keys are stored in environment variables
- Webhook signatures are verified for security
- RBAC permissions control access to payment operations
- Audit logging for all payment operations

## Testing

Run the test suite:

```bash
php artisan test --filter=PaymentServiceTest
php artisan test --filter=PosControllerTest
```

## Migration

Run the migration to add payment fields to invoices:

```bash
php artisan migrate
```

## Webhook Setup

### Stripe Webhooks

1. Go to Stripe Dashboard > Webhooks
2. Add endpoint: `https://your-domain.com/api/v1/payments/webhook`
3. Select events: `checkout.session.completed`, `payment_intent.succeeded`, `payment_intent.payment_failed`
4. Copy the webhook secret to `STRIPE_WEBHOOK_SECRET`

### Mollie Webhooks

1. Go to Mollie Dashboard > Webhooks
2. Add URL: `https://your-domain.com/api/v1/payments/webhook`
3. Copy the API key to `MOLLIE_API_KEY`

## GoBD Compliance

The DATEV export includes:
- Invoice numbers and dates
- Customer information
- Net, tax, and gross amounts
- Payment methods and providers
- Salon information for multi-tenant support

## Error Handling

The system includes comprehensive error handling:
- Provider-specific error messages
- Validation for payment amounts
- Webhook signature verification
- Graceful fallbacks for failed operations
