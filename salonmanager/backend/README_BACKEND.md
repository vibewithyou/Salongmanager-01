<!--
  Backend README (German), code comments in English in source files.
-->

# Backend – Laravel 12 (Ziel)

Dieses Backend zielt auf Laravel 12 mit PHP 8.3 und MySQL 8. Authentifizierung via Sanctum. API ist versioniert unter `/api/v1/...`. Alle Ressourcen sind mandanten-/salon-gebunden und werden serverseitig strikt gefiltert (Hard-Filter).

## Kernpunkte
- Auth: Sanctum für SPAs/PWAs und Mobile Token-Flows
- Security: CORS nur definierte Origins, Rate-Limits, RBAC, Audit-Logs
- Mandantenfähigkeit: Tenant-Resolver (z. B. per Header/Domain), Query-Scopes als Hard-Filter
- API-Versionierung: `/api/v1/...` mit stabilen Contracts (siehe `docs/api/`)

## Module (Platzhalter)
- Auth, RBAC, Salon, Booking, Staff, Customer, Loyalty, Gallery_KI, Inventory, Billing_POS, Search_Map, Reports

## Routen
- Healthcheck: `GET /api/v1/health` → `{ status: "ok", version: "v1" }`
- Admin-Panel: `GET /admin` → "Coming soon"

## Audit-Logs
Erfassen sicherheitsrelevanter und geschäftskritischer Aktionen (CRUD, RBAC-Änderungen). TODO: Struktur und Storage definieren.

## Migrationsplan (TODO – textuell)
1. tenants (Mandanten/Salons) – Basis-Stammdaten, Settings, Themes
2. users – Basis, Mandanten-Bezug, Verifizierungen
3. roles, permissions, role_user, permission_role – RBAC-Grundlage
4. audit_logs – entity, actor, action, metadata
5. staff – Profile, Skills, Arbeitszeiten
6. services & pricing – buchbare Leistungen
7. bookings – Termine, Status, Regeln
8. customers – Profile, Präferenzen, DSGVO-Flags
9. loyalty – Punkte, Rewards, Transaktionen
10. inventory – Artikel, Bestände, Bewegungen
11. billing & pos – Rechnungen, Zahlungen, Kassenbelege
12. media/gallery – Medien, KI-Pipelines (TODO)

> Hinweise: Keine Dummy-Daten. Seeder nur für technische Defaults (später).

