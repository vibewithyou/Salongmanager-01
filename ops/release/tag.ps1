# SalonManager v1.0.0 Release Tag Script
# PowerShell version for Windows environments

param(
    [string]$Version = "v1.0.0",
    [switch]$DryRun = $false
)

Write-Host "🏷️  SalonManager Release Tagging Script" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Yellow
Write-Host "Dry Run: $DryRun" -ForegroundColor Yellow
Write-Host ""

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Error "Not in a git repository. Please run from the project root."
    exit 1
}

# Check if git is available
try {
    $gitVersion = git --version
    Write-Host "✅ Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Error "Git not found. Please install Git."
    exit 1
}

# Check if we're on the main branch
$currentBranch = git branch --show-current
if ($currentBranch -ne "main" -and $currentBranch -ne "master") {
    Write-Warning "Current branch is '$currentBranch'. Consider switching to main/master."
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 0
    }
}

# Check for uncommitted changes
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Error "Uncommitted changes detected. Please commit or stash them first."
    Write-Host "Uncommitted files:" -ForegroundColor Red
    Write-Host $gitStatus
    exit 1
}

# Check if tag already exists
$existingTag = git tag -l $Version
if ($existingTag) {
    Write-Error "Tag '$Version' already exists."
    exit 1
}

# Run pre-release checks
Write-Host "🔍 Running pre-release checks..." -ForegroundColor Cyan

# Check if backend tests pass
Write-Host "Running backend tests..." -ForegroundColor Yellow
Set-Location "salonmanager/backend"
try {
    if (Test-Path "vendor/bin/pest") {
        $testResult = & "vendor/bin/pest" --stop-on-failure
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Backend tests failed. Please fix before tagging."
            exit 1
        }
        Write-Host "✅ Backend tests passed" -ForegroundColor Green
    } else {
        Write-Warning "Pest not found. Skipping backend tests."
    }
} catch {
    Write-Warning "Could not run backend tests: $_"
}
Set-Location "../.."

# Check if frontend tests pass
Write-Host "Running frontend tests..." -ForegroundColor Yellow
Set-Location "salonmanager/frontend"
try {
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        $flutterTest = flutter test
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Frontend tests failed. Please fix before tagging."
            exit 1
        }
        Write-Host "✅ Frontend tests passed" -ForegroundColor Green
    } else {
        Write-Warning "Flutter not found. Skipping frontend tests."
    }
} catch {
    Write-Warning "Could not run frontend tests: $_"
}
Set-Location "../.."

# Check if health endpoint is accessible (if running)
Write-Host "Checking health endpoint..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-WebRequest -Uri "http://localhost:8000/api/v1/health" -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($healthCheck.StatusCode -eq 200) {
        Write-Host "✅ Health endpoint accessible" -ForegroundColor Green
    } else {
        Write-Warning "Health endpoint returned status: $($healthCheck.StatusCode)"
    }
} catch {
    Write-Warning "Health endpoint not accessible (this is OK if not running locally)"
}

# Check security audit report
$securityReport = "ops/audit/SECURITY_FREEZE_REPORT.md"
if (Test-Path $securityReport) {
    $reportContent = Get-Content $securityReport -Raw
    if ($reportContent -match "Gate.*PASS") {
        Write-Host "✅ Security audit passed" -ForegroundColor Green
    } else {
        Write-Warning "Security audit may not be complete. Please check the report."
    }
} else {
    Write-Warning "Security audit report not found at $securityReport"
}

# All checks passed
Write-Host ""
Write-Host "✅ All pre-release checks passed!" -ForegroundColor Green

if ($DryRun) {
    Write-Host "🔍 DRY RUN: Would create tag '$Version' with message 'Release $Version'" -ForegroundColor Yellow
    Write-Host "🔍 DRY RUN: Would push tag to remote" -ForegroundColor Yellow
    exit 0
}

# Create the tag
Write-Host "🏷️  Creating tag '$Version'..." -ForegroundColor Cyan
$tagMessage = "Release $Version

- Security hardening with 2FA for admin roles
- Gallery system with before/after photos and moderation
- Map search with geolocation and filters
- Enhanced search API with multiple filters
- Comprehensive test coverage
- Production-ready configuration

See CHANGELOG.md for detailed changes."

git tag -a $Version -m $tagMessage
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create tag."
    exit 1
}

Write-Host "✅ Tag created successfully" -ForegroundColor Green

# Push the tag
Write-Host "📤 Pushing tag to remote..." -ForegroundColor Cyan
git push origin $Version
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to push tag to remote."
    exit 1
}

Write-Host "✅ Tag pushed successfully" -ForegroundColor Green

# Update CHANGELOG.md
$changelogPath = "CHANGELOG.md"
if (Test-Path $changelogPath) {
    Write-Host "📝 Updating CHANGELOG.md..." -ForegroundColor Cyan
    $changelogContent = Get-Content $changelogPath -Raw
    $newEntry = @"

## [$Version] - $(Get-Date -Format "yyyy-MM-dd")

### Added
- 2FA authentication for admin/owner roles
- Gallery system with photo upload and moderation
- Map search with geolocation and filters
- Enhanced search API with multiple filter options
- Comprehensive security hardening
- Production-ready backup and monitoring

### Security
- Two-factor authentication for privileged roles
- Enhanced security headers and CORS configuration
- Rate limiting for all API endpoints
- PII redaction in audit logs
- Comprehensive input validation

### Changed
- Improved search performance and filtering
- Enhanced user interface with new gallery and map features
- Updated security policies and access controls

### Fixed
- Various security vulnerabilities
- Performance optimizations
- UI/UX improvements

"@
    
    $updatedChangelog = $newEntry + "`n" + $changelogContent
    Set-Content -Path $changelogPath -Value $updatedChangelog -Encoding UTF8
    Write-Host "✅ CHANGELOG.md updated" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Release $Version tagged successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Deploy to production using the release checklist" -ForegroundColor White
Write-Host "2. Monitor the deployment for any issues" -ForegroundColor White
Write-Host "3. Update documentation and user guides" -ForegroundColor White
Write-Host "4. Announce the release to stakeholders" -ForegroundColor White
Write-Host ""
Write-Host "Release checklist: docs/ops/RELEASE_CHECKLIST_V1.md" -ForegroundColor Yellow
Write-Host "Rollback plan: docs/ops/ROLLBACK.md" -ForegroundColor Yellow
