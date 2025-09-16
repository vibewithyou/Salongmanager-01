# Loyalty Program API

## Overview

The loyalty program allows customers to earn and redeem points for services. Points are tracked through transactions and can be adjusted by staff members.

## Points Logic

### Earning Points
- Points are typically earned after service completion
- Point values are configurable per service type
- Bonus points can be awarded for special promotions
- Points can be manually adjusted by staff

### Redeeming Points
- Points can be redeemed for discounts on future services
- Redemption rates are configurable
- Points expire based on tier and salon policy
- Redemption history is tracked

### Point Tiers
- **Bronze**: 0-99 points
- **Silver**: 100-499 points  
- **Gold**: 500+ points

Tier benefits and point expiration policies are configurable per salon.

## API Endpoints

### Get Loyalty Card
```
GET /api/v1/customers/{customer}/loyalty
```

Returns the customer's current loyalty card and transaction history.

**Response:**
```json
{
  "card": {
    "id": 1,
    "points": 150,
    "meta": {
      "tier": "silver",
      "expires_at": "2024-12-31",
      "last_earned": "2024-01-15T10:30:00Z"
    }
  },
  "transactions": [
    {
      "id": 1,
      "delta": 50,
      "reason": "Haircut service",
      "meta": {
        "service_id": 123,
        "booking_id": 456
      },
      "created_at": "2024-01-15T10:30:00Z"
    },
    {
      "id": 2,
      "delta": -25,
      "reason": "Redeemed for discount",
      "meta": {
        "discount_amount": 5.00,
        "booking_id": 789
      },
      "created_at": "2024-01-10T14:20:00Z"
    }
  ]
}
```

### Adjust Points
```
POST /api/v1/customers/{customer}/loyalty/adjust
```

Manually adjust customer's loyalty points.

**Request Body:**
```json
{
  "delta": 50,
  "reason": "Service completed - Haircut"
}
```

**Response:**
```json
{
  "card": {
    "id": 1,
    "points": 200,
    "meta": {
      "tier": "silver",
      "expires_at": "2024-12-31"
    }
  },
  "transaction": {
    "id": 3,
    "delta": 50,
    "reason": "Service completed - Haircut",
    "created_at": "2024-01-15T11:00:00Z"
  }
}
```

## Transaction Types

### Service Completion
- **Delta**: Positive points based on service value
- **Reason**: "Service completed - {service_name}"
- **Meta**: Contains service_id and booking_id

### Manual Adjustment
- **Delta**: Can be positive or negative
- **Reason**: Staff-provided reason
- **Meta**: Additional context if needed

### Redemption
- **Delta**: Negative points
- **Reason**: "Redeemed for discount"
- **Meta**: Contains discount_amount and booking_id

### Refund
- **Delta**: Negative points (reversing previous earning)
- **Reason**: "Service refund"
- **Meta**: Contains original transaction reference

### Expiration
- **Delta**: Negative points
- **Reason**: "Points expired"
- **Meta**: Contains expiration policy details

## Business Rules

### Point Earning
1. Points are earned immediately after service completion
2. Point values are calculated as percentage of service price
3. Bonus multipliers can be applied for special promotions
4. Minimum service amount may be required to earn points

### Point Redemption
1. Points can only be redeemed for future services
2. Minimum redemption amount may be required
3. Maximum redemption percentage per service may be limited
4. Points cannot be redeemed for cash

### Point Expiration
1. Points expire based on customer tier
2. Expiration is calculated from last earning date
3. Expired points are automatically deducted
4. Customers are notified before points expire

## Integration with POS

The loyalty system integrates with the POS system for:

- Automatic point earning after payment
- Point redemption during checkout
- Real-time point balance updates
- Transaction history synchronization

## Example Scenarios

### New Customer
1. Customer books first appointment
2. Completes service and pays
3. System automatically creates loyalty card
4. Points are earned based on service value
5. Customer receives welcome message with point balance

### Regular Customer
1. Customer books appointment
2. Completes service and pays
3. Points are automatically added to account
4. If tier threshold is reached, customer is upgraded
5. Customer receives notification of new tier benefits

### Point Redemption
1. Customer books appointment
2. During checkout, customer requests point redemption
3. System calculates available points and discount amount
4. Points are deducted from account
5. Transaction is recorded with redemption details

### Staff Manual Adjustment
1. Staff member notices incorrect point balance
2. Staff adjusts points with appropriate reason
3. Transaction is recorded with staff member ID
4. Customer is notified of adjustment if significant

## Error Handling

### Insufficient Points
When attempting to redeem more points than available:
```json
{
  "message": "Insufficient points for redemption",
  "available_points": 50,
  "requested_points": 100
}
```

### Invalid Delta
When providing invalid point adjustment:
```json
{
  "message": "Invalid point adjustment",
  "errors": {
    "delta": ["Delta must be between -10000 and 10000"]
  }
}
```

## Security Considerations

- Only authorized staff can adjust points
- All point adjustments are logged with staff member ID
- Point redemption requires customer authentication
- Suspicious activity triggers alerts

## Future Enhancements

- Integration with external loyalty programs
- Gamification elements (badges, achievements)
- Social sharing of loyalty status
- Partner merchant point earning
- Advanced analytics and reporting