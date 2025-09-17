# Flutter Audit Script for Windows
$ROOT = Get-Location
Write-Host "Flutter Audit for Salongmanager" -ForegroundColor Green

Write-Host "`n== Flutter Version ==" -ForegroundColor Yellow
flutter --version

Write-Host "`n== Flutter Doctor ==" -ForegroundColor Yellow
flutter doctor -v

Write-Host "`n== Dependencies ==" -ForegroundColor Yellow
Set-Location "$ROOT\salonmanager\frontend"
flutter pub get

Write-Host "`n== Flutter Analyze ==" -ForegroundColor Yellow
flutter analyze

Write-Host "`n== PWA Manifest Check ==" -ForegroundColor Yellow
if (Test-Path "web\manifest.json") {
    $manifest = Get-Content "web\manifest.json" | ConvertFrom-Json
    Write-Host "✓ Manifest found" -ForegroundColor Green
    Write-Host "  Name: $($manifest.name)"
    Write-Host "  Theme Color: $($manifest.theme_color)"
    Write-Host "  Background Color: $($manifest.background_color)"
    Write-Host "  Icons: $($manifest.icons.Count)"
} else {
    Write-Host "✗ Manifest not found" -ForegroundColor Red
}

Write-Host "`n== Icons Check ==" -ForegroundColor Yellow
if (Test-Path "web\icons") {
    $icons = Get-ChildItem "web\icons" -File
    Write-Host "✓ Icons directory found" -ForegroundColor Green
    Write-Host "  Files: $($icons.Count)"
    foreach ($icon in $icons) {
        Write-Host "    - $($icon.Name)"
    }
} else {
    Write-Host "✗ Icons directory missing" -ForegroundColor Red
    Write-Host "  Create icons: icon-192.png, icon-512.png, icon-maskable.png"
}

Write-Host "`n== Web Build Test ==" -ForegroundColor Yellow
Write-Host "To test web build, run: flutter build web --release"

Write-Host "`n== Flutter Audit Complete ==" -ForegroundColor Green
Set-Location $ROOT
