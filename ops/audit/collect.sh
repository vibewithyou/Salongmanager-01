#!/usr/bin/env bash
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT="$ROOT/ops/audit/report.md"
mkdir -p "$ROOT/ops/audit"

echo "# SalonManager Production Audit Report" > "$OUT"
date >> "$OUT"

echo "## Tenant" >> "$OUT"
echo "Tables missing salon_id:" >> "$OUT"
cat "$ROOT/ops/audit/tenant_missing_salon.txt" >> "$OUT" || echo "none" >> "$OUT"
echo "" >> "$OUT"
echo "Tables missing index(salon_id):" >> "$OUT"
cat "$ROOT/ops/audit/tenant_missing_index.txt" >> "$OUT" || echo "none" >> "$OUT"

echo "## Routes" >> "$OUT"
echo "(unguarded /api/v1 routes)" >> "$OUT"
cat "$ROOT/ops/audit/unguarded_routes.txt" >> "$OUT" || echo "none" >> "$OUT"

echo "## Security" >> "$OUT"
cat "$ROOT/ops/audit/security.txt" >> "$OUT" || echo "no security file" >> "$OUT"

echo "## TODO (high-level)" >> "$OUT"
cat "$ROOT/ops/audit/todo.md" >> "$OUT" || echo "- (create todo.md)" >> "$OUT"

echo "Report built: $OUT"
