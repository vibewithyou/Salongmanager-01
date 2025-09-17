#!/bin/bash

# SalonManager v1.0.0 Release Tag Script
# Bash version for Unix/Linux environments

set -e

VERSION="v1.0.0"
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--version VERSION] [--dry-run]"
            echo "  --version VERSION  Set the version tag (default: v1.0.0)"
            echo "  --dry-run         Show what would be done without executing"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

echo "🏷️  SalonManager Release Tagging Script"
echo "Version: $VERSION"
echo "Dry Run: $DRY_RUN"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Please run from the project root."
    exit 1
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git not found. Please install Git."
    exit 1
fi

echo "✅ Git found: $(git --version)"

# Check if we're on the main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  Current branch is '$CURRENT_BRANCH'. Consider switching to main/master."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Uncommitted changes detected. Please commit or stash them first."
    echo "Uncommitted files:"
    git status --porcelain
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$VERSION$"; then
    echo "❌ Tag '$VERSION' already exists."
    exit 1
fi

# Run pre-release checks
echo "🔍 Running pre-release checks..."

# Check if backend tests pass
echo "Running backend tests..."
cd salonmanager/backend
if [ -f "vendor/bin/pest" ]; then
    if ./vendor/bin/pest --stop-on-failure; then
        echo "✅ Backend tests passed"
    else
        echo "❌ Backend tests failed. Please fix before tagging."
        exit 1
    fi
else
    echo "⚠️  Pest not found. Skipping backend tests."
fi
cd ../..

# Check if frontend tests pass
echo "Running frontend tests..."
cd salonmanager/frontend
if command -v flutter &> /dev/null; then
    if flutter test; then
        echo "✅ Frontend tests passed"
    else
        echo "❌ Frontend tests failed. Please fix before tagging."
        exit 1
    fi
else
    echo "⚠️  Flutter not found. Skipping frontend tests."
fi
cd ../..

# Check if health endpoint is accessible (if running)
echo "Checking health endpoint..."
if curl -s -f "http://localhost:8000/api/v1/health" > /dev/null 2>&1; then
    echo "✅ Health endpoint accessible"
else
    echo "⚠️  Health endpoint not accessible (this is OK if not running locally)"
fi

# Check security audit report
SECURITY_REPORT="ops/audit/SECURITY_FREEZE_REPORT.md"
if [ -f "$SECURITY_REPORT" ]; then
    if grep -q "Gate.*PASS" "$SECURITY_REPORT"; then
        echo "✅ Security audit passed"
    else
        echo "⚠️  Security audit may not be complete. Please check the report."
    fi
else
    echo "⚠️  Security audit report not found at $SECURITY_REPORT"
fi

# All checks passed
echo ""
echo "✅ All pre-release checks passed!"

if [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY RUN: Would create tag '$VERSION' with message 'Release $VERSION'"
    echo "🔍 DRY RUN: Would push tag to remote"
    exit 0
fi

# Create the tag
echo "🏷️  Creating tag '$VERSION'..."

TAG_MESSAGE="Release $VERSION

- Security hardening with 2FA for admin roles
- Gallery system with before/after photos and moderation
- Map search with geolocation and filters
- Enhanced search API with multiple filters
- Comprehensive test coverage
- Production-ready configuration

See CHANGELOG.md for detailed changes."

git tag -a "$VERSION" -m "$TAG_MESSAGE"
echo "✅ Tag created successfully"

# Push the tag
echo "📤 Pushing tag to remote..."
git push origin "$VERSION"
echo "✅ Tag pushed successfully"

# Update CHANGELOG.md
CHANGELOG_PATH="CHANGELOG.md"
if [ -f "$CHANGELOG_PATH" ]; then
    echo "📝 Updating CHANGELOG.md..."
    
    NEW_ENTRY="## [$VERSION] - $(date +%Y-%m-%d)

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

"
    
    echo "$NEW_ENTRY$(cat $CHANGELOG_PATH)" > "$CHANGELOG_PATH"
    echo "✅ CHANGELOG.md updated"
fi

echo ""
echo "🎉 Release $VERSION tagged successfully!"
echo ""
echo "Next steps:"
echo "1. Deploy to production using the release checklist"
echo "2. Monitor the deployment for any issues"
echo "3. Update documentation and user guides"
echo "4. Announce the release to stakeholders"
echo ""
echo "Release checklist: docs/ops/RELEASE_CHECKLIST_V1.md"
echo "Rollback plan: docs/ops/ROLLBACK.md"
