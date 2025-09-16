# Booking API

## Overview
The booking API provides endpoints for creating, managing, and tracking salon appointments with availability checking, buffer times, and conflict resolution.

## Endpoints

### POST /api/v1/bookings
Create a new booking with availability checking and conflict suggestions.

**Request Body:**
```json
{
  "customer_id": 123,
  "stylist_id": 456,
  "service_id": 789,
  "start_at": "2025-06-01T10:00:00Z",
  "duration": 60,
  "buffer_before": 15,
  "buffer_after": 10,
  "note": "Please use organic products",
  "media_ids": [1, 2, 3],
  "suggest_if_conflict": true
}
```

**Response:**
- **201 Created** - Booking created successfully
```json
{
  "booking": {
    "id": 1234,
    "salon_id": 1,
    "customer_id": 123,
    "stylist_id": 456,
    "service_id": 789,
    "start_at": "2025-06-01T10:00:00Z",
    "end_at": "2025-06-01T11:00:00Z",
    "duration": 60,
    "buffer_before": 15,
    "buffer_after": 10,
    "status": "pending",
    "note": "Please use organic products"
  }
}
```

- **409 Conflict** - Time slot not available
```json
{
  "error": "conflict",
  "suggestions": [
    "2025-06-01T09:00:00Z",
    "2025-06-01T11:15:00Z",
    "2025-06-01T13:00:00Z"
  ]
}
```

### POST /api/v1/bookings/{id}/status
Update booking status (confirm, decline, or cancel).

**Authorization:** 
- `confirm/decline`: Requires `modify` permission (stylist for own bookings, owner/manager for all)
- `cancel`: Requires `cancel` permission (customer for own bookings, stylist/owner/manager for assigned)

**Request Body:**
```json
{
  "action": "confirm|decline|cancel",
  "reason": "Optional reason text"
}
```

**Response:**
```json
{
  "booking": {
    "id": 1234,
    "status": "confirmed|declined|canceled",
    // ... other booking fields
  },
  "fee_rate": 0.2  // Only for cancel action, 0.0-1.0
}
```

### POST /api/v1/bookings/{id}/media
Attach media files to a booking.

**Authorization:** Requires role: `salon_owner`, `salon_manager`, or `stylist`

**Request Body:**
```json
{
  "media_ids": [10, 11, 12]
}
```

**Response:**
```json
{
  "ok": true
}
```

## Availability Logic

The availability service checks the following conditions:

1. **Opening Hours**: Booking must be within salon opening hours for the given weekday
2. **Stylist Absences**: No overlap with registered stylist absences
3. **Existing Bookings**: No conflict with confirmed or pending bookings
4. **Buffer Times**: Respects buffer_before and buffer_after for spacing between appointments

### Time Conflict Detection
A time conflict occurs when:
- New booking overlaps with existing booking time ranges
- Buffer zones of bookings overlap
- Booking extends outside opening hours
- Booking falls within stylist absence periods

### Suggestion Algorithm
When conflicts occur and `suggest_if_conflict` is true:
- Searches ±2 hours around requested time
- Returns up to 6 available slots
- Aligns suggestions to 15-minute intervals
- Checks all availability constraints for each suggestion

## Status Workflow

```
pending → confirmed (by stylist/manager)
        → declined (by stylist/manager)
        → canceled (by customer/stylist/manager)
```

## Cancellation Policy

- **Free cancellation**: More than 24 hours before appointment
- **20% fee**: Less than 24 hours before appointment
- Fee rate is returned in the response for transparency

## Events

The following events are triggered:
- `App\Events\Booking\Created` - When booking is created
- `App\Events\Booking\Confirmed` - When booking is confirmed
- `App\Events\Booking\Declined` - When booking is declined  
- `App\Events\Booking\Canceled` - When booking is canceled

## Error Codes

- `400` - Invalid request data
- `401` - Unauthenticated
- `403` - Unauthorized (RBAC policy violation)
- `404` - Booking not found
- `409` - Time slot conflict
- `422` - Validation error