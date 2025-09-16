# Staff Scheduling - Role Matrix

## Permission Matrix

| Action | Salon Owner | Salon Manager | Stylist | Customer |
|--------|-------------|---------------|---------|----------|
| **View Shifts** | ✅ | ✅ | ✅ | ❌ |
| **Create Shifts** | ✅ | ✅ | ❌ | ❌ |
| **Update Shifts** | ✅ | ✅ | Own only* | ❌ |
| **Delete Shifts** | ✅ | ✅ | ❌ | ❌ |
| **Move Shifts** | ✅ | ✅ | Own only* | ❌ |
| **Resize Shifts** | ✅ | ✅ | Own only* | ❌ |
| **View Absences** | ✅ | ✅ | ✅ | ❌ |
| **Create Absences** | ✅ | ✅ | ✅ | ❌ |
| **Update Absences** | ✅ | ✅ | Own only** | ❌ |
| **Delete Absences** | ✅ | ✅ | ❌ | ❌ |
| **Approve Absences** | ✅ | ✅ | ❌ | ❌ |

*Own only: Stylists can only modify their own shifts, and only planned shifts can be confirmed/canceled
**Own only: Stylists can only modify their own absence requests, and only when status is 'requested'

## Business Rules

### Shift Management
- Only salon owners and managers can create new shifts
- Stylists can confirm or cancel their own planned shifts
- Stylists cannot delete shifts, only managers/owners can
- Drag & drop operations (move/resize) follow the same permission rules as updates

### Absence Management
- All staff roles can create absence requests
- Only managers/owners can approve or reject requests
- Stylists can edit their own requests only while they are in 'requested' status
- Once approved or rejected, only managers/owners can modify

### Data Isolation
- All operations are scoped to the current salon (tenant isolation)
- Users can only see data for their assigned salon
- Cross-salon access is not permitted

## Security Considerations

- All endpoints require authentication (`auth:sanctum`)
- All endpoints require tenant context (`tenant.required`)
- Role-based middleware enforces permissions at the route level
- Policies provide additional authorization checks at the model level
- Input validation ensures data integrity and prevents injection attacks