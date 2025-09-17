<?php
/**
 * Standalone Audit Script for SalonManager
 * Runs without Laravel dependencies to check production readiness
 */

echo "=== SalonManager Production Readiness Audit ===\n";
echo "Date: " . date('Y-m-d H:i:s') . "\n\n";

$root = dirname(__DIR__, 2);
$backend = $root . '/salonmanager/backend';
$frontend = $root . '/frontend';
$ops = $root . '/ops';

// Create audit directory
$auditDir = $ops . '/audit';
if (!is_dir($auditDir)) {
    mkdir($auditDir, 0777, true);
}

$report = [];

// 1. Check for salon_id in database migrations
echo "1. Checking tenant isolation (salon_id)...\n";
$migrationFiles = glob($backend . '/database/migrations/*.php');
$tablesWithSalonId = [];
$tablesWithoutSalonId = [];

foreach ($migrationFiles as $file) {
    $content = file_get_contents($file);
    $filename = basename($file);
    
    // Extract table name from migration
    if (preg_match('/create_(\w+)_table/', $filename, $matches)) {
        $tableName = $matches[1];
    } elseif (preg_match('/table\([\'"]([^\'"]+)[\'"]/', $content, $matches)) {
        $tableName = $matches[1];
    } else {
        continue;
    }
    
    if (strpos($content, 'salon_id') !== false) {
        $tablesWithSalonId[] = $tableName;
    } else {
        $tablesWithoutSalonId[] = $tableName;
    }
}

$report['tenant'] = [
    'tables_with_salon_id' => count($tablesWithSalonId),
    'tables_without_salon_id' => count($tablesWithoutSalonId),
    'missing_tables' => $tablesWithoutSalonId
];

echo "   Tables with salon_id: " . count($tablesWithSalonId) . "\n";
echo "   Tables without salon_id: " . count($tablesWithoutSalonId) . "\n";

// 2. Check API routes for protection
echo "\n2. Checking API route protection...\n";
$apiFile = $backend . '/routes/api.php';
$apiContent = file_exists($apiFile) ? file_get_contents($apiFile) : '';

$protectedRoutes = 0;
$unprotectedRoutes = 0;
$unguardedRoutes = [];

if ($apiContent) {
    $lines = explode("\n", $apiContent);
    foreach ($lines as $line) {
        if (strpos($line, 'Route::') !== false && strpos($line, 'api/v1') !== false) {
            if (strpos($line, 'auth:sanctum') !== false && strpos($line, 'tenant.required') !== false) {
                $protectedRoutes++;
            } else {
                $unprotectedRoutes++;
                $unguardedRoutes[] = trim($line);
            }
        }
    }
}

$report['routes'] = [
    'protected_routes' => $protectedRoutes,
    'unprotected_routes' => $unprotectedRoutes,
    'unguarded_routes' => $unguardedRoutes
];

echo "   Protected routes: $protectedRoutes\n";
echo "   Unprotected routes: $unprotectedRoutes\n";

// 3. Check security middleware
echo "\n3. Checking security implementation...\n";
$middlewareDir = $backend . '/app/Http/Middleware';
$securityChecks = [
    'csp_middleware' => file_exists($middlewareDir . '/SecureHeaders.php'),
    'throttle_middleware' => file_exists($middlewareDir . '/ThrottleRequests.php'),
    'tenant_middleware' => file_exists($middlewareDir . '/TenantRequired.php'),
];

$report['security'] = $securityChecks;

foreach ($securityChecks as $check => $exists) {
    echo "   $check: " . ($exists ? 'OK' : 'MISSING') . "\n";
}

// 4. Check PWA implementation
echo "\n4. Checking PWA implementation...\n";
$pwaChecks = [
    'manifest_exists' => file_exists($frontend . '/web/manifest.json'),
    'icon_192' => file_exists($frontend . '/web/icons/icon-192.png'),
    'icon_512' => file_exists($frontend . '/web/icons/icon-512.png'),
    'icon_maskable' => file_exists($frontend . '/web/icons/icon-maskable.png'),
];

$report['pwa'] = $pwaChecks;

foreach ($pwaChecks as $check => $exists) {
    echo "   $check: " . ($exists ? 'OK' : 'MISSING') . "\n";
}

// 5. Check for critical missing files
echo "\n5. Checking critical files...\n";
$criticalFiles = [
    'docker_compose' => file_exists($root . '/docker-compose.yml'),
    'github_actions' => is_dir($root . '/.github/workflows'),
    'env_example' => file_exists($backend . '/.env.example'),
    'readme' => file_exists($root . '/README.md'),
];

$report['critical_files'] = $criticalFiles;

foreach ($criticalFiles as $file => $exists) {
    echo "   $file: " . ($exists ? 'OK' : 'MISSING') . "\n";
}

// 6. Check test coverage
echo "\n6. Checking test coverage...\n";
$testFiles = glob($backend . '/tests/**/*.php');
$testCount = count($testFiles);

$report['tests'] = [
    'test_files' => $testCount,
    'has_feature_tests' => count(glob($backend . '/tests/Feature/*.php')) > 0,
    'has_unit_tests' => count(glob($backend . '/tests/Unit/*.php')) > 0,
];

echo "   Test files: $testCount\n";
echo "   Feature tests: " . ($report['tests']['has_feature_tests'] ? 'YES' : 'NO') . "\n";
echo "   Unit tests: " . ($report['tests']['has_unit_tests'] ? 'YES' : 'NO') . "\n";

// Generate report
echo "\n=== Generating Report ===\n";
$reportContent = "# SalonManager Production Audit Report\n";
$reportContent .= "Generated: " . date('Y-m-d H:i:s') . "\n\n";

$reportContent .= "## Summary\n";
$reportContent .= "- Tables with salon_id: " . $report['tenant']['tables_with_salon_id'] . "\n";
$reportContent .= "- Tables without salon_id: " . $report['tenant']['tables_without_salon_id'] . "\n";
$reportContent .= "- Protected API routes: " . $report['routes']['protected_routes'] . "\n";
$reportContent .= "- Unprotected API routes: " . $report['routes']['unprotected_routes'] . "\n";
$reportContent .= "- Test files: " . $report['tests']['test_files'] . "\n\n";

$reportContent .= "## Critical Issues\n";
if ($report['tenant']['tables_without_salon_id'] > 0) {
    $reportContent .= "- " . $report['tenant']['tables_without_salon_id'] . " tables missing salon_id (tenant isolation)\n";
}
if ($report['routes']['unprotected_routes'] > 0) {
    $reportContent .= "- " . $report['routes']['unprotected_routes'] . " API routes not properly protected\n";
}
if (!$report['security']['csp_middleware']) {
    $reportContent .= "- CSP middleware missing\n";
}
if (!$report['security']['tenant_middleware']) {
    $reportContent .= "- Tenant middleware missing\n";
}
if (!$report['critical_files']['docker_compose']) {
    $reportContent .= "- Docker configuration missing\n";
}
if (!$report['critical_files']['github_actions']) {
    $reportContent .= "- CI/CD pipeline missing\n";
}

file_put_contents($auditDir . '/report.md', $reportContent);
file_put_contents($auditDir . '/audit_data.json', json_encode($report, JSON_PRETTY_PRINT));

echo "Report saved to: " . $auditDir . '/report.md' . "\n";
echo "Data saved to: " . $auditDir . '/audit_data.json' . "\n";

echo "\n=== Audit Complete ===\n";
