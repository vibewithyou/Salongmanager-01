# MOVE_TO_BACKEND — Inventory/Customer/GDPR

- Alle Backend-Klassen gehören nach `salonmanager/backend/...`.
- Composer PSR-4 bleibt `App\\ => app/`.
- Inventory- und GDPR-Dateien wurden aus Repo-Root/Secondary-Backend verschoben.
- Orphan-Scanner (`php artisan repo:scan-orphans`) schlägt in CI fehl, wenn wieder Dateien außerhalb abgelegt werden.
- Nach Merge:
  - PaymentController-Hook → StockService funktioniert.
  - `/api/v1/inventory/*` Endpunkte erreichbar.
  - GDPR-Routen unter `/api/v1/gdpr`.

## Files Moved

### Inventory Module
- Controllers: `app/Http/Controllers/Inventory/*` → `salonmanager/backend/app/Http/Controllers/Inventory/`
- Requests: `app/Http/Requests/Inventory/*` → `salonmanager/backend/app/Http/Requests/Inventory/`
- Models: Product, ProductPrice, StockItem, StockLocation, StockMovement, Supplier, PurchaseOrder, PurchaseOrderItem
- Services: `app/Services/Inventory/*` → `salonmanager/backend/app/Services/Inventory/`
- Policy: `app/Policies/InventoryPolicy.php` → `salonmanager/backend/app/Policies/`
- Migrations: All 600xxx series migrations

### Customer Module
- Models: CustomerProfile, CustomerNote, CustomerMedia, LoyaltyCard, LoyaltyTransaction, Discount
- Policies: CustomerPolicy, CustomerNotePolicy, LoyaltyPolicy
- Requests: `app/Http/Requests/Customer/*` → `salonmanager/backend/app/Http/Requests/Customer/`
- Migrations: All 300xxx series migrations

### GDPR Module
- Controller: `backend/app/Http/Controllers/GdprController.php` → `salonmanager/backend/app/Http/Controllers/`
- Migration: `backend/database/migrations/*gdpr*.php` → `salonmanager/backend/database/migrations/`

## Cleanup Required
See `/salonmanager/ops/repo/cleanup_list.txt` for files to delete after confirming the migration works.

## Testing
- Run `php artisan repo:scan-orphans` to verify no files are misplaced
- Test inventory endpoints: `GET /api/v1/inventory/products`
- Test GDPR endpoints: `POST /api/v1/gdpr/export`
- Run tests: `php artisan test --filter=InventorySmokeTest`
- Run tests: `php artisan test --filter=PosStockDeductionTest`