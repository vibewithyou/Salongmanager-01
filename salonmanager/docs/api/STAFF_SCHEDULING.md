# Staff Scheduling API

## Overview

This document describes the API endpoints for managing staff scheduling, including shifts and absences.

## Endpoints

### Shifts

#### GET /api/v1/staff/shifts
Retrieve shifts with optional filtering.

**Query Parameters:**
- `from` (optional): ISO date string - filter shifts starting from this date
- `to` (optional): ISO date string - filter shifts ending before this date
- `stylist_id` (optional): integer - filter shifts for specific stylist

**Response:**
```json
{
  "shifts": [
    {
      "id": 1,
      "stylist_id": 5,
      "start_at": "2024-01-15T09:00:00Z",
      "end_at": "2024-01-15T17:00:00Z",
      "status": "planned",
      "meta": {"color": "#3B82F6"},
      "stylist": {
        "id": 5,
        "name": "Anna Müller"
      }
    }
  ]
}
```

#### POST /api/v1/staff/shifts
Create a new shift.

**Request Body:**
```json
{
  "stylist_id": 5,
  "start_at": "2024-01-15T09:00:00Z",
  "end_at": "2024-01-15T17:00:00Z",
  "status": "planned",
  "meta": {"color": "#3B82F6"}
}
```

#### PUT /api/v1/staff/shifts/{id}
Update an existing shift.

#### DELETE /api/v1/staff/shifts/{id}
Delete a shift.

#### POST /api/v1/staff/shifts/{id}/move
Move a shift to new start/end times (for drag & drop).

**Request Body:**
```json
{
  "start_at": "2024-01-15T10:00:00Z",
  "end_at": "2024-01-15T18:00:00Z"
}
```

#### POST /api/v1/staff/shifts/{id}/resize
Resize a shift by changing only the end time.

**Request Body:**
```json
{
  "end_at": "2024-01-15T19:00:00Z"
}
```

### Absences

#### GET /api/v1/staff/absences
Retrieve absences with optional filtering.

**Query Parameters:**
- `stylist_id` (optional): integer - filter absences for specific stylist

#### POST /api/v1/staff/absences
Create a new absence request.

**Request Body:**
```json
{
  "stylist_id": 5,
  "from_date": "2024-01-20",
  "to_date": "2024-01-22",
  "type": "vacation",
  "note": "Family vacation"
}
```

#### PUT /api/v1/staff/absences/{id}
Update an existing absence.

#### DELETE /api/v1/staff/absences/{id}
Delete an absence.

#### POST /api/v1/staff/absences/{id}/approve
Approve an absence request.

## Status Values

### Shift Status
- `planned`: Newly created shift, not yet confirmed
- `confirmed`: Shift confirmed by stylist
- `swapped`: Shift has been swapped with another stylist
- `canceled`: Shift has been canceled

### Absence Status
- `requested`: Initial status when created by stylist
- `approved`: Approved by manager/owner
- `rejected`: Rejected by manager/owner

### Absence Types
- `vacation`: Vacation time
- `sick`: Sick leave
- `other`: Other reasons

## Role-Based Access Control

### Salon Owner/Manager
- Can view, create, update, and delete all shifts and absences
- Can approve/reject absence requests
- Can move and resize any shift

### Stylist
- Can view all shifts and absences
- Can create absence requests
- Can update own absence requests (only when status is 'requested')
- Can update own shifts (confirm/cancel planned shifts)
- Can move and resize own shifts

## Calendar Feed Integration

The shifts endpoint supports calendar feed queries with `from` and `to` parameters for efficient date range filtering. This enables calendar views to load only relevant data for the displayed time period.

## Drag & Drop Semantics

- **Move**: Changes both start and end times while preserving duration
- **Resize**: Changes only the end time, effectively changing duration

Both operations include validation to ensure:
- End time is after start time
- No overlapping shifts for the same stylist (TODO: collision detection with bookings)