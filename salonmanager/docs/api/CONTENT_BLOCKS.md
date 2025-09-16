# Content Blocks API

## Overview
The Content Blocks API manages dynamic content blocks for salon pages. Each salon can have multiple content blocks that are rendered in order based on their position.

## Endpoints

### GET /api/v1/salon/blocks
**Public endpoint** - Returns all active content blocks for the salon

**Headers:**
- `X-Salon-Slug`: Required tenant identifier

**Response:**
```json
{
  "blocks": [
    {
      "id": 1,
      "type": "hero",
      "title": "Welcome to Our Salon",
      "config": {
        "headline": "Professional Beauty Services",
        "sub": "Experience luxury and quality in every treatment"
      },
      "is_active": true,
      "position": 0,
      "updated_at": "2024-01-15T10:30:00Z"
    },
    {
      "id": 2,
      "type": "text",
      "title": "About Us",
      "config": {
        "text": "We are a premium beauty salon dedicated to providing exceptional services..."
      },
      "is_active": true,
      "position": 1,
      "updated_at": "2024-01-15T10:35:00Z"
    }
  ]
}
```

### POST /api/v1/salon/blocks
**Protected endpoint** - Creates a new content block

**Authentication:** Required (Sanctum)
**Authorization:** `salon_owner` or `salon_manager` roles

**Request Body:**
```json
{
  "type": "hero",
  "title": "New Hero Block",
  "config": {
    "headline": "Welcome",
    "sub": "Subtitle text"
  },
  "is_active": true,
  "position": 0
}
```

**Response:**
```json
{
  "block": {
    "id": 3,
    "type": "hero",
    "title": "New Hero Block",
    "config": {
      "headline": "Welcome",
      "sub": "Subtitle text"
    },
    "is_active": true,
    "position": 0,
    "created_at": "2024-01-15T11:00:00Z",
    "updated_at": "2024-01-15T11:00:00Z"
  }
}
```

### GET /api/v1/salon/blocks/{id}
**Protected endpoint** - Returns a specific content block

### PUT /api/v1/salon/blocks/{id}
**Protected endpoint** - Updates a content block

### DELETE /api/v1/salon/blocks/{id}
**Protected endpoint** - Deletes a content block

## Content Block Types

### Hero Block
**Type:** `hero`

**Config Schema:**
```json
{
  "headline": "string (required)",
  "sub": "string (optional)",
  "bg_image": "string (optional, image URL)"
}
```

**Example:**
```json
{
  "type": "hero",
  "title": "Welcome Section",
  "config": {
    "headline": "Professional Beauty Services",
    "sub": "Experience luxury and quality in every treatment",
    "bg_image": "/uploads/hero-bg.jpg"
  }
}
```

### Text Block
**Type:** `text`

**Config Schema:**
```json
{
  "text": "string (required, HTML supported)"
}
```

**Example:**
```json
{
  "type": "text",
  "title": "About Us",
  "config": {
    "text": "<p>We are a premium beauty salon dedicated to providing exceptional services to our valued clients.</p>"
  }
}
```

### Call-to-Action Block
**Type:** `cta`

**Config Schema:**
```json
{
  "label": "string (required)",
  "target": "string (optional, URL or route)",
  "style": "string (optional, 'primary' | 'secondary')"
}
```

**Example:**
```json
{
  "type": "cta",
  "title": "Book Appointment",
  "config": {
    "label": "Book Now",
    "target": "/booking",
    "style": "primary"
  }
}
```

### Gallery Block
**Type:** `gallery`

**Config Schema:**
```json
{
  "images": [
    {
      "url": "string (required)",
      "alt": "string (optional)",
      "caption": "string (optional)"
    }
  ],
  "layout": "string (optional, 'grid' | 'masonry' | 'carousel')"
}
```

**Example:**
```json
{
  "type": "gallery",
  "title": "Our Work",
  "config": {
    "images": [
      {
        "url": "/uploads/gallery1.jpg",
        "alt": "Hair styling example",
        "caption": "Professional hair styling"
      },
      {
        "url": "/uploads/gallery2.jpg",
        "alt": "Makeup example",
        "caption": "Bridal makeup"
      }
    ],
    "layout": "grid"
  }
}
```

## Field Descriptions

### Common Fields
- `id`: Unique identifier (integer, auto-generated)
- `type`: Block type identifier (string, max 50 chars, required)
- `title`: Display title (string, max 190 chars, optional)
- `config`: Type-specific configuration (JSON object, optional)
- `is_active`: Whether the block is visible (boolean, default: true)
- `position`: Sort order (integer, 0-1000, default: 0)
- `salon_id`: Associated salon ID (integer, auto-set by tenant scope)

### Validation Rules
- `type`: Required, string, max 50 characters
- `title`: Optional, string, max 190 characters
- `config`: Optional, must be valid JSON
- `is_active`: Optional, boolean
- `position`: Optional, integer between 0-1000

## Error Responses

### 401 Unauthorized
```json
{
  "message": "Unauthenticated."
}
```

### 403 Forbidden
```json
{
  "message": "This action is unauthorized."
}
```

### 404 Not Found
```json
{
  "message": "No query results for model [App\\Models\\ContentBlock] {id}"
}
```

### 422 Validation Error
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "type": ["The type field is required."],
    "position": ["The position must be between 0 and 1000."]
  }
}
```

## Notes
- All blocks are automatically scoped to the current tenant (salon)
- Blocks are returned in position order (ascending)
- Only active blocks (`is_active: true`) are typically displayed
- The `config` field accepts any valid JSON structure
- Image URLs in gallery blocks should be absolute paths or full URLs
- HTML is supported in text blocks for rich formatting