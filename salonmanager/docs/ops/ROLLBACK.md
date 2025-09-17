# Rollback Plan v1.0.0

## Overview

This document outlines the rollback procedures for SalonManager v1.0.0 in case of critical issues during or after deployment.

## Rollback Triggers

- Critical security vulnerabilities discovered
- Data corruption or loss
- Performance degradation > 50%
- Service unavailability > 5 minutes
- Customer data breach

## Rollback Procedures

### 1. Immediate Response (0-5 minutes)

1. **Activate Maintenance Mode**
   ```bash
   php artisan down --message="Emergency maintenance in progress"
   ```

2. **Notify Stakeholders**
   - Send alert to admin team
   - Update status page
   - Notify customers if necessary

### 2. Database Rollback (5-15 minutes)

1. **Stop Application Services**
   ```bash
   # Docker
   docker-compose -f docker-compose.prod.yml down
   
   # Or systemd
   sudo systemctl stop salonmanager-backend
   sudo systemctl stop salonmanager-frontend
   ```

2. **Restore Database from Backup**
   ```bash
   # Find latest backup
   ls -la storage/app/backups/
   
   # Restore database
   php artisan backup:restore --disk=local --backup=latest
   
   # Or manual restore
   mysql -u username -p database_name < backup_file.sql
   ```

3. **Restore File Storage**
   ```bash
   # Extract storage backup
   tar -xzf storage/app/backups/storage_backup.tar.gz -C storage/app/
   ```

### 3. Application Rollback (15-30 minutes)

1. **Revert to Previous Git Tag**
   ```bash
   # Checkout previous stable version
   git checkout v0.9.0
   
   # Or specific commit
   git checkout <previous-commit-hash>
   ```

2. **Update Dependencies**
   ```bash
   # Backend
   cd salonmanager/backend
   composer install --no-dev --optimize-autoloader
   
   # Frontend
   cd salonmanager/frontend
   flutter pub get
   flutter build web --release
   ```

3. **Run Migrations (if needed)**
   ```bash
   php artisan migrate --force
   ```

### 4. Service Restoration (30-45 minutes)

1. **Restart Services**
   ```bash
   # Docker
   docker-compose -f docker-compose.prod.yml up -d
   
   # Or systemd
   sudo systemctl start salonmanager-backend
   sudo systemctl start salonmanager-frontend
   ```

2. **Verify Services**
   ```bash
   # Health check
   curl -f http://localhost:8000/api/v1/health
   
   # Check logs
   docker-compose -f docker-compose.prod.yml logs -f
   ```

3. **Disable Maintenance Mode**
   ```bash
   php artisan up
   ```

### 5. Post-Rollback Verification (45-60 minutes)

1. **Functional Testing**
   - [ ] User authentication works
   - [ ] Core features functional
   - [ ] Data integrity verified
   - [ ] Performance acceptable

2. **Security Verification**
   - [ ] No security vulnerabilities
   - [ ] Access controls working
   - [ ] Data protection active

3. **Monitoring**
   - [ ] Error rates normal
   - [ ] Response times acceptable
   - [ ] No critical alerts

## Rollback Decision Matrix

| Issue Severity | Response Time | Rollback Required |
|----------------|---------------|-------------------|
| Critical (P0)  | < 5 minutes   | Yes               |
| High (P1)      | < 15 minutes  | Maybe             |
| Medium (P2)    | < 1 hour      | No                |
| Low (P3)       | < 4 hours     | No                |

## Communication Plan

### Internal Team
- **Immediate:** Slack alert to #ops channel
- **5 minutes:** Email to admin team
- **15 minutes:** Status update to stakeholders

### External
- **If customer impact:** Status page update
- **If data breach:** Follow GDPR notification procedures
- **If extended downtime:** Customer communication

## Recovery Time Objectives (RTO)

- **Critical Issues:** 15 minutes
- **High Issues:** 30 minutes
- **Medium Issues:** 2 hours
- **Low Issues:** 4 hours

## Recovery Point Objectives (RPO)

- **Data Loss:** < 1 hour (backup frequency)
- **Configuration:** < 5 minutes (Git-based)
- **File Storage:** < 1 hour (backup frequency)

## Prevention Measures

1. **Staging Environment**
   - Full production replica
   - Automated testing
   - Load testing

2. **Blue-Green Deployment**
   - Zero-downtime deployment
   - Instant rollback capability
   - Traffic switching

3. **Feature Flags**
   - Gradual feature rollout
   - Instant feature disable
   - A/B testing capability

## Post-Rollback Actions

1. **Root Cause Analysis**
   - Identify failure point
   - Document lessons learned
   - Update procedures

2. **Fix and Retest**
   - Address root cause
   - Comprehensive testing
   - Staging validation

3. **Re-deployment Plan**
   - Updated deployment strategy
   - Additional safeguards
   - Monitoring improvements

## Emergency Contacts

- **On-Call Engineer:** +49-XXX-XXXXXXX
- **DevOps Lead:** +49-XXX-XXXXXXX
- **Security Team:** security@salonmanager.app
- **Management:** management@salonmanager.app

## Backup Locations

- **Database Backups:** `storage/app/backups/`
- **File Storage:** `storage/app/backups/storage_backup.tar.gz`
- **Configuration:** Git repository
- **Code:** Git repository with tags

---

*Last updated: 2025-01-10*
*Next review: 2025-02-10*
