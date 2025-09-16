# Create PWA Icons Script
# Creates placeholder icons for PWA functionality

Write-Host "=== Creating PWA Icons ===" -ForegroundColor Green

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$frontend = Join-Path $root "frontend"
$iconsDir = Join-Path $frontend "web\icons"

# Create icons directory if it doesn't exist
if (!(Test-Path $iconsDir)) {
    New-Item -ItemType Directory -Path $iconsDir -Force | Out-Null
    Write-Host "Created icons directory: $iconsDir" -ForegroundColor Green
}

# Create a simple 1x1 pixel PNG (transparent)
$iconData = [Convert]::FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")

# Create icon files
$iconFiles = @(
    @{Name="icon-192.png"; Size=192},
    @{Name="icon-512.png"; Size=512},
    @{Name="icon-maskable.png"; Size=512}
)

foreach ($icon in $iconFiles) {
    $iconPath = Join-Path $iconsDir $icon.Name
    if (!(Test-Path $iconPath)) {
        [System.IO.File]::WriteAllBytes($iconPath, $iconData)
        Write-Host "Created $($icon.Name) (placeholder)" -ForegroundColor Green
    } else {
        Write-Host "$($icon.Name) already exists" -ForegroundColor Yellow
    }
}

Write-Host "`nPWA icons created successfully!" -ForegroundColor Green
Write-Host "Note: These are placeholder icons. Replace with actual salon branding." -ForegroundColor Yellow
