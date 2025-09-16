# Discounts API

## Overview

The discount system provides flexible coupon and promotion management for salons. Discounts can be percentage-based or fixed amount, with various conditions and validity periods.

## Discount Types

### Percentage Discount
- Reduces price by a percentage
- Example: 10% off all services
- Value represents percentage (e.g., 10.00 = 10%)

### Fixed Amount Discount
- Reduces price by a fixed amount
- Example: $5 off any service over $50
- Value represents currency amount

## API Endpoints

### Get Active Discounts
```
GET /api/v1/discounts
```

Returns all currently active discounts that are within their validity period.

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
        "customer_tier": "new",
        "service_ids": [1, 2, 3]
      },
      "created_at": "2024-01-01T00:00:00Z"
    },
    {
      "id": 2,
      "code": "FIXED5",
      "type": "fixed",
      "value": 5.00,
      "valid_from": "2024-01-15",
      "valid_to": "2024-02-15",
      "active": true,
      "conditions": {
        "min_amount": 30.00,
        "max_uses": 100,
        "used_count": 25
      },
      "created_at": "2024-01-15T00:00:00Z"
    }
  ]
}
```

## Discount Conditions

### Minimum Amount
- `min_amount`: Minimum service total required
- Applied before discount calculation
- Example: $50 minimum for 10% discount

### Customer Tier
- `customer_tier`: Restrict to specific customer tiers
- Values: "new", "bronze", "silver", "gold"
- Example: New customer welcome discount

### Service Restrictions
- `service_ids`: Array of specific service IDs
- `exclude_service_ids`: Array of excluded service IDs
- Example: 20% off haircuts only

### Usage Limits
- `max_uses`: Maximum number of times discount can be used
- `used_count`: Current usage count
- `max_uses_per_customer`: Per-customer usage limit

### Time Restrictions
- `valid_from`: Start date for discount validity
- `valid_to`: End date for discount validity
- `valid_days`: Specific days of week (1=Monday, 7=Sunday)
- `valid_hours`: Specific time ranges

### Customer Restrictions
- `new_customers_only`: Restrict to first-time customers
- `existing_customers_only`: Exclude new customers
- `customer_ids`: Specific customer IDs
- `exclude_customer_ids`: Excluded customer IDs

## Example Conditions

### New Customer Welcome
```json
{
  "customer_tier": "new",
  "min_amount": 25.00,
  "max_uses_per_customer": 1
}
```

### Service-Specific Discount
```json
{
  "service_ids": [1, 2, 3],
  "min_amount": 50.00,
  "max_uses": 50
}
```

### Weekend Special
```json
{
  "valid_days": [6, 7],
  "valid_hours": {
    "start": "09:00",
    "end": "17:00"
  },
  "min_amount": 40.00
}
```

### Loyalty Member Exclusive
```json
{
  "customer_tier": ["silver", "gold"],
  "min_amount": 75.00,
  "max_uses_per_customer": 3
}
```

## Discount Application Logic

### 1. Validation
- Check if discount is active
- Verify current date is within validity period
- Confirm customer meets tier requirements
- Validate minimum amount requirement

### 2. Calculation
- **Percentage**: `discount_amount = (service_total * percentage) / 100`
- **Fixed**: `discount_amount = min(fixed_value, service_total)`

### 3. Application
- Apply discount to service total
- Update usage counters
- Record transaction details
- Send confirmation to customer

## Error Responses

### Invalid Discount Code
```json
{
  "message": "Invalid discount code",
  "code": "INVALID_CODE"
}
```

### Expired Discount
```json
{
  "message": "Discount has expired",
  "code": "EXPIRED",
  "expired_at": "2024-01-01T00:00:00Z"
}
```

### Minimum Amount Not Met
```json
{
  "message": "Minimum amount not met",
  "code": "MIN_AMOUNT",
  "required_amount": 50.00,
  "current_amount": 30.00
}
```

### Usage Limit Exceeded
```json
{
  "message": "Usage limit exceeded",
  "code": "USAGE_LIMIT",
  "max_uses": 100,
  "used_count": 100
}
```

### Customer Tier Not Eligible
```json
{
  "message": "Customer tier not eligible",
  "code": "TIER_RESTRICTION",
  "required_tier": "gold",
  "customer_tier": "silver"
}
```

## Integration Points

### Booking System
- Discount codes can be applied during booking
- Real-time validation during checkout
- Automatic application based on conditions

### POS System
- Discount codes scanned/entered at checkout
- Automatic calculation and application
- Usage tracking and reporting

### Customer Portal
- Customers can view available discounts
- Apply codes during online booking
- Track usage history

## Analytics and Reporting

### Usage Metrics
- Total uses per discount
- Revenue impact
- Customer acquisition through discounts
- Most popular discount codes

### Performance Tracking
- Conversion rates
- Average discount value
- Customer lifetime value impact
- ROI on discount campaigns

## Security Considerations

- Discount codes should be unique and unpredictable
- Rate limiting on discount validation
- Audit trail for all discount applications
- Protection against code enumeration

## Future Enhancements

### Dynamic Discounts
- Time-based automatic discounts
- Weather-based promotions
- Inventory-based discounts
- Customer behavior-triggered offers

### Advanced Conditions
- Geographic restrictions
- Device-specific offers
- Social media integration
- Referral-based discounts

### Integration Features
- Email marketing integration
- SMS campaign support
- Social media promotion tools
- Affiliate program support