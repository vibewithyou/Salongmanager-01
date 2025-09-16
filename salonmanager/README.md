<!--
  SalonManager Monorepo
  Purpose: Top-level documentation in German. Code comments must stay in English.
-->

# SalonManager

Kurzbeschreibung: Ein mandantenfähiges Salon-Management-System als Monorepo. Zielplattformen: Web (PWA), Android, iOS. Backend mit Laravel 12, MySQL 8 und Sanctum; Frontend mit Flutter (Riverpod, go_router, Dio).

## Tech-Stack
- Backend: Laravel 12, PHP 8.3, MySQL 8, Sanctum
- Frontend: Flutter (stable), Riverpod, go_router, Dio
- Security: CORS nur definierte Origins, Rate-Limits, RBAC, Audit-Logs
- Mandantenfähigkeit: Alle Ressourcen salon-/tenant-gebunden, serverseitiger Hard-Filter
- API: versioniert unter `/api/v1/...`; Contracts in `docs/api/`
- CI: Lint, Tests, Build (Happy-Path pro Feature)

## Monorepo-Struktur

Siehe Ordnerstruktur im Repository. Leere Ordner werden durch `.gitkeep` vorgehalten.

## Roadmap (12 Slices)
1. Auth & Onboarding (Sanctum, Sessions, Token-Flows)
2. RBAC (Rollen, Berechtigungen, Guards)
3. Mandanten-/Salon-Basis (Tenant-Resolver, Filter, Settings)
4. Staff-Management (Profile, Verfügbarkeit)
5. Booking (Kalender, Slots, Regeln)
6. Customer (Profile, Historie, Consent)
7. Loyalty (Punkte, Rewards)
8. Inventory (Artikel, Bestände)
9. Billing & POS (Rechnungen, Zahlungen)
10. Gallery & KI (Medien, AI-Pipelines – TODO)
11. Search & Map (Standorte, Geodaten)
12. Reports (KPIs, Export)

## Konventionen
- Branching: `main` (stabil), `feat/*`, `fix/*`, `chore/*`
- Commits: Conventional Commits (z. B. `feat:`, `fix:`, `chore:`). Keine Secrets/Keys!
- Code-Style: PHP per PHP-CS-Fixer/PSR-12 (später), Dart per `dart format`, Lints per CI.
- API-Versionierung: `/api/v1/...`; Breaking Changes nur mit neuer Version.
- Security: CORS nur Whitelist, Rate-Limits, RBAC-Enforcement, Audit-Logs.

## Lokale Entwicklung (High-Level)
- Backend: Laravel 12 (später Setup), `.env` via lokale Secrets (nicht committen). DB: MySQL 8.
- Frontend: Flutter stable. Env per `--dart-define` (z. B. `API_BASE_URL`).

## Hinweise
- Keine Dummy-Daten im Repo. Wo nötig, TODOs gekennzeichnet.
- CI führt Lint/Tests/Build für Backend und Frontend aus, plus Docs-Lint.

