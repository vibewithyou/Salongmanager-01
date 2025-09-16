# 🚀 SalonManager Go Live Pack

This package contains everything needed to deploy SalonManager to production with confidence.

## 📋 Prerequisites

- Docker Desktop installed and running
- PowerShell (Windows) or Bash (Linux/Mac)
- Internet connection for package downloads

## 🚀 Quick Start

### Windows
```powershell
.\go-live.ps1
```

### Linux/Mac
```bash
chmod +x go-live.sh
./go-live.sh
```

## 📁 Scripts Overview

### Main Scripts
- **`go-live.ps1`** / **`go-live.sh`** - Complete deployment automation
- **`health-check.ps1`** - Comprehensive health verification
- **`test-webhooks.ps1`** - Payment webhook testing
- **`test-gobd.ps1`** - GoBD numbering system verification
- **`test-backups.ps1`** - Backup system testing

### Configuration Files
- **`ops/deploy/compose.prod.yml`** - Production Docker Compose configuration
- **`salonmanager/backend/.env`** - Environment configuration (auto-created)

## 🔧 What the Go Live Process Does

### 1. Environment Setup
- ✅ Creates `.env` file if missing
- ✅ Validates PHP/Composer availability
- ✅ Sets up production environment variables

### 2. Docker Stack Deployment
- ✅ Builds all required containers
- ✅ Starts services in correct order
- ✅ Configures networking and volumes

### 3. Laravel Application Setup
- ✅ Generates application key
- ✅ Runs database migrations
- ✅ Caches configuration and routes
- ✅ Sets up storage permissions

### 4. Testing & Validation
- ✅ Runs Feature tests
- ✅ Runs E2E tests
- ✅ Tests health endpoints
- ✅ Validates webhook functionality
- ✅ Tests GoBD numbering system
- ✅ Verifies backup system

### 5. Health Monitoring
- ✅ Database connectivity
- ✅ Redis connectivity
- ✅ Queue worker status
- ✅ Scheduler functionality
- ✅ File system permissions

## 🏥 Health Endpoints

- **Laravel Health**: `http://localhost/up`
- **API Health**: `http://localhost/api/v1/health`
- **Payment Webhook**: `http://localhost/api/v1/payments/webhook`

## 🔗 Webhook Testing

The webhook endpoint should return:
- **400** without signature (expected)
- **400** with invalid signature (expected)
- **200** with valid signature (production)

## 🧾 GoBD Compliance

The system implements GoBD-compliant invoice numbering:
- Format: `SM-{salon_id}-{year}-{000001}`
- Sequential numbering per salon per year
- Immutable once assigned
- Database-backed sequence tracking

## 💾 Backup System

- Automatic daily backups
- Configurable retention policies
- Database and file system backups
- Easy restore procedures

## 🚨 Troubleshooting

### Docker Not Running
```bash
# Start Docker Desktop manually
# Then re-run the go-live script
```

### Database Connection Issues
```bash
# Check if MySQL container is running
docker compose -f ops/deploy/compose.prod.yml ps db

# View database logs
docker compose -f ops/deploy/compose.prod.yml logs db
```

### Health Check Failures
```bash
# Run individual health checks
.\health-check.ps1

# Check specific service logs
docker compose -f ops/deploy/compose.prod.yml logs app
```

### Webhook Issues
```bash
# Test webhook endpoint
.\test-webhooks.ps1

# Check webhook logs
docker compose -f ops/deploy/compose.prod.yml logs app | grep webhook
```

## 📊 Production Readiness Checklist

- [ ] All health checks pass
- [ ] Feature tests pass
- [ ] E2E tests pass
- [ ] Webhook validation works
- [ ] GoBD numbering system functional
- [ ] Backup system operational
- [ ] Security headers configured
- [ ] Rate limiting active
- [ ] SSL/TLS configured (production)
- [ ] Monitoring configured
- [ ] Error tracking active

## 🔒 Security Considerations

- Environment variables properly configured
- Database credentials secured
- API keys protected
- Webhook signatures validated
- Rate limiting enabled
- Security headers active
- HTTPS enforced (production)

## 📈 Monitoring & Maintenance

### Daily
- Check health endpoints
- Monitor backup status
- Review error logs

### Weekly
- Run full test suite
- Verify webhook functionality
- Check GoBD numbering integrity

### Monthly
- Review security logs
- Update dependencies
- Test disaster recovery

## 🆘 Support

If you encounter issues during the go-live process:

1. Check the troubleshooting section above
2. Review Docker logs for specific errors
3. Verify all prerequisites are met
4. Contact the development team with specific error messages

## 📝 Post-Deployment

After successful deployment:

1. Configure production environment variables
2. Set up SSL certificates
3. Configure monitoring and alerting
4. Set up automated backups
5. Configure error tracking (Sentry)
6. Test all critical user flows
7. Monitor system performance

---

**🎉 Congratulations! Your SalonManager application is now live and ready for production use.**
