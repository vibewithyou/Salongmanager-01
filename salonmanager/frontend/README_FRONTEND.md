<!--
  Frontend README (German). Code comments in English within source files.
-->

# Frontend – Flutter (PWA, Android, iOS)

Ziel: Ein Flutter-Frontend mit Riverpod, go_router und Dio. Design in Schwarz/Gold mit Dark/Light Mode, salon-spezifisch überschreibbar.

## Stack
- Flutter (stable channel)
- Riverpod (State Management)
- go_router (Navigation)
- Dio (HTTP-Client)

## Struktur
- `lib/core/` – Theme, Localization (TODO), Routing, Env, Error Handling
- `lib/common/` – UI-Kit (Buttons, Inputs, Modals)
- `lib/services/` – API-Client (Dio), Storage, Auth
- `lib/features/` – Feature-Slices (auth, rbac, booking, ...)
- `lib/app.dart` – App-Root
- `web/` – PWA Manifest, Service Worker (TODO)

## Env
Konfiguration via `--dart-define` (z. B. `API_BASE_URL`). Keine Secrets committen.

## Tests
Widget-Test für Router-Boot (Smoke-Test) – minimal vorhanden.

