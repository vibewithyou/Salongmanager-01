#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
echo "Repo root: $ROOT"

echo "== Basic tree =="
if command -v tree >/dev/null; then
  tree -L 3 -I "vendor|node_modules|build|.dart_tool|.git|ios|android" "$ROOT" || true
else
  find "$ROOT" -maxdepth 3 -type d -not -path "*/.git*" -not -path "*/vendor*" -not -path "*/build*" | sed "s|$ROOT||g"
fi

echo "== Orphan check (Laravel files outside salonmanager/backend) =="
find "$ROOT" -maxdepth 3 -type d -name app -o -name database | grep -v "salonmanager/backend" || true

echo "== Grep TODO / FIXME / DUMMY =="
grep -RniE "TODO\\(|TODO:|FIXME|DUMMY|PLACEHOLDER" "$ROOT" --exclude-dir=vendor --exclude-dir=.git || true

echo "== Composer validate =="
cd "$ROOT/salonmanager/backend" && composer validate --no-check-lock

echo "== Composer autoload (optimize) =="
composer dump-autoload -o

echo "== PHP & Laravel info =="
php -v
php artisan --version || true

echo "== Route list (export to ops/audit/routes.txt) =="
php artisan route:list > "$ROOT/ops/audit/routes.txt" || true
echo "Route list saved to ops/audit/routes.txt"

echo "== Config cache (non-destructive) =="
php artisan config:cache || true
php artisan route:cache || true

echo "== Migrate (DRY RUN preview) =="
php artisan migrate --pretend || true

echo "== Tests (Feature only, stop on first fail) =="
php artisan test --testsuite=Feature --stop-on-failure || true

echo "== Composer security audit =="
composer audit || true

echo "== Flutter doctor/analyze =="
cd "$ROOT/salonmanager/frontend"
flutter --version || true
flutter doctor -v || true
flutter pub get
flutter analyze || true

echo "== Flutter PWA manifest quick check =="
test -f web/manifest.json && jq '.name,.icons|length' web/manifest.json || echo "manifest.json missing or jq not installed"

echo "== Icon placeholders present? =="
ls -l web/icons || echo "icons folder missing"

echo "== DONE =="
