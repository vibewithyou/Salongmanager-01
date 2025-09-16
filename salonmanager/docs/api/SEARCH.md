# Search API Documentation

## Overview

The Search API provides public endpoints for finding salons and checking availability without authentication. These endpoints are designed for cross-salon search functionality.

## Endpoints

### GET /api/v1/search/salons

Search for salons with various filters including location, text search, and availability.

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `q` | string | No | Text search query (name, city, tags) |
| `lat` | number | No | Latitude for location-based search (-90 to 90) |
| `lng` | number | No | Longitude for location-based search (-180 to 180) |
| `radius_km` | number | No | Search radius in kilometers (1-100) |
| `service_id` | integer | No | Filter by specific service ID |
| `open_now` | boolean | No | Only show salons currently open |
| `page` | integer | No | Page number (default: 1) |
| `per_page` | integer | No | Results per page (1-50, default: 20) |
| `sort` | string | No | Sort order: 'distance' or 'name' (default: 'distance' if lat/lng provided, 'name' otherwise) |

#### Example Request

```
GET /api/v1/search/salons?lat=52.5200&lng=13.4050&radius_km=10&open_now=true&q=hair
```

#### Example Response

```json
{
  "items": [
    {
      "id": 1,
      "name": "Hair Studio Berlin",
      "slug": "hair-studio-berlin",
      "logo_path": "/uploads/logos/salon1.jpg",
      "short_desc": "Premium hair styling in the heart of Berlin",
      "city": "Berlin",
      "zip": "10115",
      "lat": 52.5200,
      "lng": 13.4050,
      "distance_km": 2.3
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total": 15,
    "next_page": 2
  }
}
```

#### Features

- **Text Search**: Searches across salon name, city, and tags
- **Location Search**: Uses MySQL's spatial functions for accurate distance calculation
- **Service Filtering**: Shows only salons offering specific services
- **Open Now Filter**: Real-time check against opening hours
- **Distance Sorting**: Haversine formula for accurate distance calculation

### GET /api/v1/search/availability

Get available booking slots for a specific salon and service.

#### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `salon_id` | integer | Yes | Salon ID |
| `service_id` | integer | Yes | Service ID (must belong to the salon) |
| `from` | date | No | Start date for search (default: now) |
| `to` | date | No | End date for search (default: +14 days) |
| `limit` | integer | No | Maximum slots to return (1-10, default: 3) |

#### Example Request

```
GET /api/v1/search/availability?salon_id=1&service_id=5&limit=5
```

#### Example Response

```json
{
  "slots": [
    {
      "stylist_id": 3,
      "start_at": "2024-01-20T10:00:00Z",
      "end_at": "2024-01-20T11:30:00Z"
    },
    {
      "stylist_id": 3,
      "start_at": "2024-01-20T14:00:00Z",
      "end_at": "2024-01-20T15:30:00Z"
    }
  ]
}
```

#### Slot Calculation Logic

The availability endpoint uses a simplified slot calculation:

1. **Shift-based**: Only considers stylist shifts within the time range
2. **Service Duration**: Uses the service's `base_duration` for slot length
3. **Booking Collision**: Excludes slots that overlap with existing bookings
4. **Time Grid**: Uses 15-minute increments for slot generation
5. **Stylist Assignment**: Each slot is tied to a specific stylist

#### Limitations

- **Holiday Handling**: Currently not implemented (TODO)
- **Complex Scheduling**: Does not consider stylist preferences or advanced rules
- **Service Dependencies**: Does not handle service combinations or prerequisites
- **Buffer Times**: No buffer time between appointments

## Data Models

### Salon Fields (Public)

Only the following fields are returned in search results:

- `id`: Unique salon identifier
- `name`: Salon name
- `slug`: URL-friendly identifier
- `logo_path`: Path to salon logo image
- `short_desc`: Brief description
- `city`: City name
- `zip`: Postal code
- `lat`: Latitude (extracted from location POINT)
- `lng`: Longitude (extracted from location POINT)
- `distance_km`: Distance from search center (only when lat/lng provided)

### Opening Hours

Opening hours are stored as a simple weekly schedule:

- `weekday`: 1 (Monday) to 7 (Sunday)
- `open_time`: Opening time (HH:MM:SS)
- `close_time`: Closing time (HH:MM:SS)
- `closed`: Boolean flag for closed days

## Performance Considerations

### Database Indexes

- **Spatial Index**: `salons_location_spx` on location POINT
- **Text Indexes**: `city`, `zip` for fast filtering
- **Composite Indexes**: `(salon_id, weekday)` for opening hours

### Query Optimization

- Uses MySQL spatial functions for accurate distance calculation
- Implements proper pagination to limit result sets
- Leverages database indexes for fast text and location searches

## Error Handling

### Common Error Responses

```json
{
  "message": "Validation failed",
  "errors": {
    "lat": ["The lat field must be between -90 and 90."],
    "radius_km": ["The radius km field must be at least 1."]
  }
}
```

### HTTP Status Codes

- `200`: Success
- `400`: Bad Request (validation errors)
- `404`: Salon or Service not found
- `500`: Internal Server Error

## Future Enhancements

### Planned Features

1. **Geocoding Integration**: Reverse geocoding for address lookup
2. **Holiday Calendar**: Integration with holiday APIs
3. **Advanced Availability**: Complex scheduling rules and preferences
4. **Real-time Updates**: WebSocket support for live availability
5. **Caching**: Redis caching for frequently accessed data
6. **Analytics**: Search analytics and popular queries tracking