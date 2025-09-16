# Search Map Wireframe Documentation

## Overview

The Search Map feature provides a comprehensive salon discovery interface combining an interactive map with a results list, allowing users to find salons by location, text search, and various filters.

## Screen Layout

### Main Search Map Page

```
┌─────────────────────────────────────────────────────────┐
│ [≡] SalonManager                    [🔍] [⚙️] [👤]     │
├─────────────────────────────────────────────────────────┤
│ Search Salons                                          │
├─────────────────────────────────────────────────────────┤
│ [🔍 Search field...] [Filter: Jetzt offen] [Apply]     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │                                                 │   │
│  │              INTERACTIVE MAP                    │   │
│  │                                                 │   │
│  │    📍 Salon A    📍 Salon B                     │   │
│  │                                                 │   │
│  │              📍 Salon C                         │   │
│  │                                                 │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ Radius: [●────────────] 5 km                           │
├─────────────────────────────────────────────────────────┤
│ Results (15 found)                                      │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────┐ │
│ │ [🏪] Hair Studio Berlin                             │ │
│ │     Mitte, 10115 • Premium hair styling             │ │
│ │                                     2.3 km    [→]  │ │
│ └─────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ [🏪] Beauty Lounge                                  │ │
│ │     Kreuzberg, 10999 • Modern beauty treatments     │ │
│ │                                     1.8 km    [→]  │ │
│ └─────────────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ [🏪] Barber Shop Pro                                │ │
│ │     Friedrichshain, 10247 • Traditional barbering  │ │
│ │                                     3.2 km    [→]  │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ [Load More...]                                          │
└─────────────────────────────────────────────────────────┘
```

## Component Breakdown

### 1. App Bar with Search

**Purpose**: Primary search interface and navigation

**Elements**:
- Page title: "Salons suchen"
- Search field with magnifying glass icon
- Filter chip for "Jetzt offen" (Open Now)
- Optional: Service filter dropdown

**Behavior**:
- Real-time search as user types
- Filter chips toggle search parameters
- Search triggers map and list updates

### 2. Interactive Map

**Purpose**: Visual salon discovery and location-based search

**Features**:
- OpenStreetMap tiles for base layer
- Custom salon markers with location pins
- Tap to search at specific location
- Zoom and pan controls
- Marker clustering for dense areas (optional)

**Marker Design**:
```
    📍
   /   \
  /     \
 /       \
/_________\
```

**Interaction**:
- Tap marker → Show salon details in bottom sheet
- Tap empty area → Set search center to that location
- Drag to pan, pinch to zoom

### 3. Radius Slider

**Purpose**: Control search radius for location-based queries

**Design**:
- Horizontal slider with 1-50 km range
- Real-time radius indicator
- Visual feedback on map (optional circle overlay)

**Behavior**:
- Immediate search update on change
- Visual radius circle on map (optional)

### 4. Results List

**Purpose**: Detailed salon information in scrollable list

**Card Layout**:
```
┌─────────────────────────────────────────────────────┐
│ [🏪] Salon Name                                     │
│     City, ZIP • Short description                   │
│                                     Distance  [→]  │
└─────────────────────────────────────────────────────┘
```

**Elements per Card**:
- Salon icon/logo (placeholder if no logo)
- Salon name (primary text)
- Location (city, ZIP code)
- Short description
- Distance from search center (if location-based)
- Tap target for details

**Behavior**:
- Infinite scroll with pagination
- Tap card → Open salon detail bottom sheet
- Highlight corresponding map marker

### 5. Salon Detail Bottom Sheet

**Purpose**: Quick salon preview with availability teaser

**Layout**:
```
┌─────────────────────────────────────────────────────┐
│ ─────────────────────────────────────────────────── │
│                                                     │
│ Salon Name                                          │
│                                                     │
│ Available Slots (next 14 days):                    │
│                                                     │
│ [2024-01-20 10:00] [2024-01-20 14:00] [2024-01-21 09:00] │
│                                                     │
│                                    [Mehr anzeigen] │
└─────────────────────────────────────────────────────┘
```

**Features**:
- Drag handle for easy dismissal
- Salon name and basic info
- Next 3 available slots as buttons
- "Mehr anzeigen" (Show More) button for full booking flow

## User Flow

### 1. Initial Load
1. User navigates to `/search`
2. Map centers on default location (Berlin)
3. Search executes with default radius (5 km)
4. Results populate map markers and list

### 2. Text Search
1. User types in search field
2. Search executes on text change (debounced)
3. Map and list update with filtered results
4. Markers highlight matching salons

### 3. Location Search
1. User taps on map at desired location
2. Search center updates to tapped coordinates
3. New search executes with same radius
4. Results update based on new center

### 4. Filter Application
1. User toggles "Jetzt offen" filter
2. Search re-executes with open-now constraint
3. Only currently open salons shown
4. Map markers update accordingly

### 5. Salon Detail View
1. User taps salon marker or list item
2. Bottom sheet slides up with salon details
3. Availability slots load and display
4. User can tap slot to start booking process

## Responsive Design

### Mobile (Primary)
- Full-screen map with collapsible results
- Bottom sheet for salon details
- Touch-optimized controls
- Swipe gestures for navigation

### Tablet
- Split view: map on left, results on right
- Larger touch targets
- More detailed salon cards
- Side panel for salon details

### Desktop (Future)
- Three-panel layout: search, map, results
- Hover states for interactions
- Keyboard navigation support
- Advanced filtering options

## Accessibility

### Screen Reader Support
- Semantic HTML structure
- ARIA labels for interactive elements
- Alt text for salon logos
- Descriptive button labels

### Keyboard Navigation
- Tab order through interactive elements
- Enter key for search execution
- Arrow keys for slider control
- Escape key for modal dismissal

### Visual Accessibility
- High contrast mode support
- Scalable text and controls
- Clear visual hierarchy
- Color-blind friendly markers

## Performance Considerations

### Map Performance
- Marker clustering for >50 results
- Lazy loading of map tiles
- Efficient marker rendering
- Smooth pan/zoom animations

### List Performance
- Virtual scrolling for large result sets
- Lazy loading of salon images
- Pagination to limit initial load
- Debounced search input

### Data Loading
- Cached search results
- Progressive loading of details
- Background availability fetching
- Optimistic UI updates

## Future Enhancements

### Phase 2 Features
- Advanced filters (price range, services, ratings)
- Saved searches and favorites
- Salon comparison view
- Real-time availability updates

### Phase 3 Features
- Augmented reality salon discovery
- Voice search integration
- Social features (reviews, photos)
- Integration with booking calendar

### Analytics Integration
- Search query tracking
- Popular salon identification
- User behavior analysis
- Conversion funnel optimization