# Salon Profile API

## Overview
The Salon Profile API allows reading and updating salon branding, SEO, and content settings. All operations are tenant-scoped and require appropriate permissions.

## Endpoints

### GET /api/v1/salon/profile
**Public endpoint** - Returns salon profile information

**Headers:**
- `X-Salon-Slug`: Required tenant identifier

**Response:**
```json
{
  "salon": {
    "id": 1,
    "name": "Beauty Salon",
    "slug": "beauty-salon",
    "logo_path": "/uploads/logo.png",
    "primary_color": "#FF6B6B",
    "secondary_color": "#4ECDC4",
    "brand": {
      "font_family": "Inter",
      "corner_radius": 8,
      "dark_mode_default": false
    },
    "seo": {
      "title": "Beauty Salon - Professional Hair & Beauty Services",
      "description": "Professional hair styling, beauty treatments, and wellness services",
      "keywords": ["hair salon", "beauty", "styling", "wellness"]
    },
    "social": {
      "instagram": "https://instagram.com/beautysalon",
      "tiktok": "https://tiktok.com/@beautysalon",
      "website": "https://beautysalon.com"
    },
    "content_settings": {
      "show_booking_button": true,
      "show_contact_info": true,
      "layout_style": "modern"
    }
  }
}
```

### PUT /api/v1/salon/profile
**Protected endpoint** - Updates salon profile

**Authentication:** Required (Sanctum)
**Authorization:** `salon_owner`, `salon_manager`, `owner`, or `platform_admin` roles

**Headers:**
- `X-Salon-Slug`: Required tenant identifier
- `Authorization`: Bearer token or session cookie

**Request Body:**
```json
{
  "name": "Updated Salon Name",
  "primary_color": "#FF6B6B",
  "secondary_color": "#4ECDC4",
  "brand": {
    "font_family": "Inter",
    "corner_radius": 12,
    "dark_mode_default": true
  },
  "seo": {
    "title": "New SEO Title",
    "description": "Updated description",
    "keywords": ["new", "keywords"]
  },
  "social": {
    "instagram": "https://instagram.com/newsalon",
    "tiktok": "https://tiktok.com/@newsalon"
  },
  "content_settings": {
    "show_booking_button": false,
    "layout_style": "minimal"
  }
}
```

**Response:**
```json
{
  "ok": true,
  "salon": {
    // Updated salon object
  }
}
```

## Field Descriptions

### Basic Information
- `name`: Salon display name (string, max 190 chars)
- `slug`: URL-friendly identifier (string, max 190 chars)
- `logo_path`: Path to salon logo image (string, max 255 chars, nullable)
- `primary_color`: Primary brand color in hex format (string, max 20 chars, nullable)
- `secondary_color`: Secondary brand color in hex format (string, max 20 chars, nullable)

### Brand Settings (JSON)
- `font_family`: Preferred font family for UI
- `corner_radius`: Border radius for UI elements (number)
- `dark_mode_default`: Whether to default to dark mode (boolean)

### SEO Settings (JSON)
- `title`: Page title for SEO
- `description`: Meta description
- `keywords`: Array of SEO keywords

### Social Links (JSON)
- `instagram`: Instagram profile URL
- `tiktok`: TikTok profile URL
- `website`: Salon website URL

### Content Settings (JSON)
- `show_booking_button`: Whether to display booking CTA (boolean)
- `show_contact_info`: Whether to show contact information (boolean)
- `layout_style`: UI layout preference (string)

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

### 422 Validation Error
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "name": ["The name field is required."],
    "primary_color": ["The primary color format is invalid."]
  }
}
```

## Notes
- All fields are optional in update requests (using `sometimes` validation)
- Color values should be in hex format (e.g., "#FF6B6B")
- JSON fields accept any valid JSON structure
- Logo uploads are handled separately (TODO: implement upload endpoint)