# GoBD Numbering System Test Script
# Tests the GoBD-compliant invoice numbering system

Write-Host "🧾 Testing GoBD Numbering System..." -ForegroundColor Yellow

# Test GoBD numbering system
Write-Host "Creating test salon and invoice..." -ForegroundColor Cyan

$testScript = @"
`$s = App\Models\Salon::first() ?? App\Models\Salon::factory()->create();
`$i = App\Models\Invoice::factory()->create(['salon_id' => `$s->id, 'status' => 'draft', 'total_gross' => 9.99]);
if (method_exists(`$i, 'finalizeNumber')) {
    `$i->finalizeNumber();
    echo "Invoice number: " . `$i->number;
} else {
    echo "finalizeNumber method not found";
}
"@

Write-Host "Running GoBD test via Docker..." -ForegroundColor Cyan
docker compose -f ops/deploy/compose.prod.yml exec -T app php artisan tinker --execute="$testScript"

Write-Host "`n✅ GoBD numbering test completed!" -ForegroundColor Green
