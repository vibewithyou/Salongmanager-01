# Release Checklist

## Pre-Release Checklist

### Database & Migrations
- [ ] All migrations executed successfully in production
- [ ] Database backup created before migration
- [ ] No pending migrations (`php artisan migrate:status`)
- [ ] Database indexes optimized for performance

### Security & Rate Limiting
- [ ] Scoped rate limits active on all critical routes
- [ ] Rate limits configured per role (guest/customer/stylist/manager/owner)
- [ ] Webhook signatures verified and enforced
- [ ] Idempotency keys implemented for webhooks and POS operations
- [ ] Security audit passed with no critical issues

### GoBD Compliance
- [ ] Invoice numbering system implemented (sequential, per salon, per year)
- [ ] Invoice sequences are transaction-safe with database locks
- [ ] No gaps in invoice numbering
- [ ] Invoice finalization happens before payment processing

### API & Documentation
- [ ] OpenAPI specification validated in CI
- [ ] API documentation up to date
- [ ] All endpoints have proper rate limiting
- [ ] Webhook endpoints have signature verification

### Testing
- [ ] All unit tests passing
- [ ] All feature tests passing
- [ ] E2E happy path tests passing
- [ ] No N+1 query issues detected
- [ ] Performance tests within acceptable limits

### Performance & Monitoring
- [ ] Database indexes added for critical queries
- [ ] N+1 query guards implemented
- [ ] Query performance optimized
- [ ] Memory usage within limits
- [ ] Response times acceptable

### Frontend & PWA
- [ ] Flutter web build successful
- [ ] PWA icons and manifest present
- [ ] Service worker functioning correctly
- [ ] Frontend tests passing
- [ ] UI/UX reviewed and approved

### Infrastructure
- [ ] CI/CD pipeline configured with release gates
- [ ] All required environment variables set
- [ ] SSL certificates valid
- [ ] CDN configured (if applicable)
- [ ] Monitoring and alerting configured

### GDPR & Compliance
- [ ] GDPR export functionality working
- [ ] Data deletion requests handled
- [ ] Privacy policy updated
- [ ] Cookie consent implemented
- [ ] Data retention policies in place

## Release Process

### 1. Pre-Release Validation
```bash
# Run all tests
php artisan test

# Check migrations
php artisan migrate:status

# Run security audit
php ops/audit/standalone_audit.php

# Validate OpenAPI
# (handled by CI)
```

### 2. Staging Deployment
- [ ] Deploy to staging environment
- [ ] Run smoke tests on staging
- [ ] Verify all critical paths work
- [ ] Check performance metrics
- [ ] Validate webhook endpoints

### 3. Production Deployment
- [ ] Deploy to production (only if all checks pass)
- [ ] Monitor application health
- [ ] Verify critical business functions
- [ ] Check error logs
- [ ] Monitor performance metrics

### 4. Post-Release
- [ ] Monitor application for 24 hours
- [ ] Check error rates and performance
- [ ] Verify all integrations working
- [ ] Update documentation if needed
- [ ] Communicate release to stakeholders

## Rollback Plan

### Immediate Rollback (if critical issues)
1. Revert to previous stable version
2. Restore database backup if needed
3. Verify system stability
4. Investigate and fix issues
5. Plan re-deployment

### Gradual Rollback (if minor issues)
1. Disable affected features via feature flags
2. Monitor system stability
3. Fix issues in development
4. Deploy fixes when ready

## Emergency Contacts

- **Lead Developer**: [Name] - [Phone] - [Email]
- **DevOps Engineer**: [Name] - [Phone] - [Email]
- **Product Owner**: [Name] - [Phone] - [Email]
- **On-call Support**: [Phone] - [Email]

## Release Notes Template

### Version X.X.X - [Date]

#### New Features
- [Feature 1]
- [Feature 2]

#### Improvements
- [Improvement 1]
- [Improvement 2]

#### Bug Fixes
- [Bug fix 1]
- [Bug fix 2]

#### Security Updates
- [Security update 1]
- [Security update 2]

#### Breaking Changes
- [Breaking change 1] (if any)
- [Breaking change 2] (if any)

#### Migration Notes
- [Migration step 1]
- [Migration step 2]

---

**Release Manager**: [Name]  
**Release Date**: [Date]  
**Deployment Time**: [Time]  
**Rollback Time**: [Time] (if applicable)
