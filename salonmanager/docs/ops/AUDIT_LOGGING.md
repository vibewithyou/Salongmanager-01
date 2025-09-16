# Audit Logging

## Ziele
- Nachvollziehbarkeit sensibler Aktionen (auth, booking, pos, media, rbac, gdpr, price).
- Tenant-aware, DSGVO-konform (keine PII im Klartext).

## API
- `Audit::write(action, entityType?, entityId?, meta=[])`
- Events & Listener binden gängige Flows automatisch ein.

## Felder
- `action` (string), `entity_type` (string), `entity_id` (id), `meta` (json),
- Request-Kontext: `ip`, `ua`, `method`, `path`.

## Best Practices
- Keine Karten-/Bankdaten, keine vollständigen E-Mails/Telefonnummern in `meta`.
- Nur IDs, Summen, Status, Kurzhinweise.