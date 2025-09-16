# GDPR Self-Service (Backend)

## Endpoints

- **POST /api/v1/gdpr/export** → legt Request an, dispatch Job, 202 Accepted
- **GET /api/v1/gdpr/exports/{id}** → Status & Meta
- **GET /api/v1/gdpr/exports/{id}/download** → ZIP (bei `done`)
- **POST /api/v1/gdpr/delete** → Löschantrag (pending)
- **POST /api/v1/gdpr/delete/{id}/confirm** → Admin bestätigt → Anonymisierung

## Speicherung

- Export-Artefakte unter Disk `exports`, Pfad: `salon_{id}/user_{id}/Y/m/d/gdpr_{id}.zip`.

## Datenschutz

- Keine Löschung von Rechnungen (GoBD). Nutzer-Personendaten werden anonymisiert.
- Audit-Events: export.request/download, delete.request/confirm.
- Optional: Benachrichtigungen (siehe Notifications-Modul).

## Implementation Details

### Models
- **GdprRequest**: Stores GDPR requests with type (export/delete), status tracking
- Uses `SalonOwned` trait for multi-tenancy

### Jobs
- **BuildExportJob**: Asynchronous job to build user data export
  - Collects user profile, bookings, invoices, reviews, loyalty data
  - Creates JSON file with all personal data
  - Packages into ZIP file
  - Stores in exports disk

### Events
- **ExportRequested**: Fired when export is requested
- **Exported**: Fired when export is completed
- **DeletionRequested**: Fired when deletion is requested  
- **DeletionConfirmed**: Fired when admin confirms deletion

### Security
- Self-service endpoints require authentication
- Users can only access their own GDPR requests
- Admin confirmation required for deletions (owner/platform_admin/salon_owner roles)
- All actions are audit logged

### Compliance Notes
- User deletion is implemented as anonymization (name → '[deleted]', email/phone → null)
- Invoices and financial records are preserved for tax compliance (GoBD)
- All personal data exports include related data (bookings, reviews, loyalty, etc.)