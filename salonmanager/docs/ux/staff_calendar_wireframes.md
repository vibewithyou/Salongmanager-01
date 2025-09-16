# Staff Calendar - UI Wireframes

## Overview

The staff calendar provides three different views for managing shifts and absences: Day, Week, and Month views.

## Day View

```
┌─────────────────────────────────────────┐
│ Dienstplan                    [View ▼] │
├─────────────────────────────────────────┤
│                                         │
│ 09:00 ┌─────────────────┐               │
│       │ Anna Müller     │               │
│       │ 09:00 - 17:00   │               │
│       │ planned         │               │
│       └─────────────────┘               │
│                                         │
│ 10:00 ┌─────────────────┐               │
│       │ Max Schmidt     │               │
│       │ 10:00 - 18:00   │               │
│       │ confirmed       │               │
│       └─────────────────┘               │
│                                         │
│ 14:00 ┌─────────────────┐               │
│       │ Lisa Weber      │               │
│       │ 14:00 - 22:00   │               │
│       │ planned         │               │
│       └─────────────────┘               │
│                                         │
└─────────────────────────────────────────┘
                    [+ Schicht]
```

## Week View

```
┌─────────────────────────────────────────────────────────────────┐
│ Dienstplan                    [View ▼]                         │
├─────────────────────────────────────────────────────────────────┤
│ Mo    │ Di    │ Mi    │ Do    │ Fr    │ Sa    │ So             │
├───────┼───────┼───────┼───────┼───────┼───────┼───────────────┤
│       │       │       │       │       │       │                │
│ Anna  │ Anna  │       │ Anna  │ Anna  │       │                │
│ 9-17  │ 9-17  │       │ 9-17  │ 9-17  │       │                │
│       │       │       │       │       │       │                │
│ Max   │ Max   │ Max   │ Max   │ Max   │       │                │
│ 10-18 │ 10-18 │ 10-18 │ 10-18 │ 10-18 │       │                │
│       │       │       │       │       │       │                │
│       │ Lisa  │ Lisa  │ Lisa  │ Lisa  │ Lisa  │                │
│       │ 14-22 │ 14-22 │ 14-22 │ 14-22 │ 14-22 │                │
│       │       │       │       │       │       │                │
└───────┴───────┴───────┴───────┴───────┴───────┴────────────────┘
                    [+ Schicht]
```

## Month View

```
┌─────────────────────────────────────────────────────────────────┐
│ Dienstplan                    [View ▼]                         │
├─────────────────────────────────────────────────────────────────┤
│ Mo    │ Di    │ Mi    │ Do    │ Fr    │ Sa    │ So             │
├───────┼───────┼───────┼───────┼───────┼───────┼───────────────┤
│ 1     │ 2     │ 3     │ 4     │ 5     │ 6     │ 7             │
│ 2 Sch │ 1 Sch │ 0 Sch │ 3 Sch │ 2 Sch │ 0 Sch │ 0 Sch         │
├───────┼───────┼───────┼───────┼───────┼───────┼───────────────┤
│ 8     │ 9     │ 10    │ 11    │ 12    │ 13    │ 14            │
│ 1 Sch │ 2 Sch │ 1 Sch │ 2 Sch │ 3 Sch │ 1 Sch │ 0 Sch         │
├───────┼───────┼───────┼───────┼───────┼───────┼───────────────┤
│ 15    │ 16    │ 17    │ 18    │ 19    │ 20    │ 21            │
│ 2 Sch │ 2 Sch │ 1 Sch │ 2 Sch │ 1 Sch │ 0 Sch │ 0 Sch         │
├───────┼───────┼───────┼───────┼───────┼───────┼───────────────┤
│ 22    │ 23    │ 24    │ 25    │ 26    │ 27    │ 28            │
│ 1 Sch │ 1 Sch │ 0 Sch │ 0 Sch │ 2 Sch │ 1 Sch │ 0 Sch         │
├───────┼───────┼───────┼───────┼───────┼───────┼───────────────┤
│ 29    │ 30    │ 31    │       │       │       │                │
│ 2 Sch │ 1 Sch │ 1 Sch │       │       │       │                │
└───────┴───────┴───────┴───────┴───────┴───────┴────────────────┘
                    [+ Schicht]
```

## Color Coding

### Shift Status Colors
- **Planned**: Secondary color (gray/blue)
- **Confirmed**: Primary color (blue)
- **Swapped**: Tertiary color (green)
- **Canceled**: Error color (red)

### Stylist Colors
Each stylist can have a unique color assigned in their meta data for easy visual identification across all views.

## Interactive Elements

### Shift Cards
- Click to view details
- Right-click or menu button for actions (Edit, Move, Resize, Delete)
- Drag & drop support for moving shifts (future enhancement)
- Resize handles for changing duration (future enhancement)

### View Switching
- Dropdown menu in app bar to switch between Day/Week/Month views
- Current view is highlighted
- View preference can be persisted in user settings

### Floating Action Button
- Primary action: Create new shift
- Secondary actions: Create absence request, view templates (future)

## Responsive Design

- **Mobile**: Stack day columns vertically in week view
- **Tablet**: Show 3-4 day columns in week view
- **Desktop**: Show full 7-day week view
- Month view adapts grid size based on screen width

## Future Enhancements

- Drag & drop for moving shifts between time slots
- Resize handles for adjusting shift duration
- Bulk operations (select multiple shifts)
- Print/export functionality
- Integration with external calendar apps
- Real-time updates via WebSocket