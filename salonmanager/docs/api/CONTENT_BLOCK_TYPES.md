# Content Block Types Reference

## Overview
This document provides detailed schemas and examples for each supported content block type.

## Block Types

### 1. Hero Block
**Purpose:** Eye-catching header section with headline and subtitle

**Type Identifier:** `hero`

**Config Schema:**
```typescript
{
  headline: string;        // Main headline text (required)
  sub?: string;           // Subtitle text (optional)
  bgImage?: string;       // Background image URL (optional)
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
    "bgImage": "/uploads/hero-background.jpg"
  }
}
```

**Rendering Notes:**
- Displays as a prominent banner with gradient background
- Headline uses large, bold typography
- Subtitle appears below headline in smaller text
- Background image (if provided) overlays with gradient

### 2. Text Block
**Purpose:** Rich text content with optional title

**Type Identifier:** `text`

**Config Schema:**
```typescript
{
  text: string;           // HTML content (required)
}
```

**Example:**
```json
{
  "type": "text",
  "title": "About Our Salon",
  "config": {
    "text": "<p>We are a premium beauty salon dedicated to providing exceptional services to our valued clients. Our team of experienced professionals uses only the highest quality products and latest techniques.</p><p>Visit us today and experience the difference that professional care can make.</p>"
  }
}
```

**Rendering Notes:**
- Supports HTML formatting (paragraphs, bold, italic, links)
- Title appears above content if provided
- Content is wrapped in a bordered container
- Text is left-aligned with proper spacing

### 3. Call-to-Action Block
**Purpose:** Prominent button or action prompt

**Type Identifier:** `cta`

**Config Schema:**
```typescript
{
  label: string;          // Button text (required)
  target?: string;        // URL or route (optional)
  style?: 'primary' | 'secondary'; // Button style (optional)
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

**Rendering Notes:**
- Displays as an elevated button
- Uses primary theme color by default
- Button text is centered and padded
- Click action navigates to target (TODO: implement navigation)

### 4. Gallery Block
**Purpose:** Image gallery with various layout options

**Type Identifier:** `gallery`

**Config Schema:**
```typescript
{
  images: Array<{
    url: string;          // Image URL (required)
    alt?: string;         // Alt text (optional)
    caption?: string;     // Image caption (optional)
  }>;
  layout?: 'grid' | 'masonry' | 'carousel'; // Layout style (optional)
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
        "url": "/uploads/hair-styling-1.jpg",
        "alt": "Professional hair styling",
        "caption": "Elegant updo styling"
      },
      {
        "url": "/uploads/makeup-1.jpg",
        "alt": "Bridal makeup",
        "caption": "Natural bridal look"
      },
      {
        "url": "/uploads/nails-1.jpg",
        "alt": "Nail art design",
        "caption": "Creative nail art"
      }
    ],
    "layout": "grid"
  }
}
```

**Rendering Notes:**
- Currently shows placeholder text (TODO: implement image rendering)
- Supports multiple layout styles
- Images should be optimized for web display
- Alt text improves accessibility

## Custom Block Types

### Naming Convention
Custom block types should follow the pattern: `custom-{name}`

**Examples:**
- `custom-testimonials`
- `custom-services`
- `custom-pricing`

### Implementation
Custom blocks require:
1. Backend validation rules (if needed)
2. Frontend rendering logic in `SalonPage._buildBlock()`
3. Documentation for config schema

## Best Practices

### Content Guidelines
- Keep headlines concise and impactful
- Use high-quality images for galleries
- Ensure all text is proofread and professional
- Test all links and navigation targets

### Performance
- Optimize images before upload
- Limit gallery images to reasonable numbers
- Use appropriate image dimensions
- Consider lazy loading for large galleries

### Accessibility
- Provide alt text for all images
- Use semantic HTML in text blocks
- Ensure sufficient color contrast
- Test with screen readers

## Future Block Types (Planned)

### Services Block
- Display salon services with pricing
- Config: services array with name, description, price

### Testimonials Block
- Customer reviews and ratings
- Config: testimonials array with text, author, rating

### Contact Block
- Contact information and map
- Config: address, phone, email, map coordinates

### Social Feed Block
- Instagram or social media integration
- Config: social platform, account, post count

## Migration Notes
- Block types are extensible without database changes
- New types require frontend rendering implementation
- Backward compatibility maintained for existing blocks
- Unsupported types display as placeholder with type name