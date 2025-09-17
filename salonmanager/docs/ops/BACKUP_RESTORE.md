# Backup & Restore Documentation

## Overview

This document describes how to perform backups and restores for the SalonManager application using Spatie Laravel Backup.

## Backup Configuration

Backups are configured to run automatically via the Laravel scheduler:
- **Cleanup**: Daily at 02:00 AM
- **Backup Creation**: Daily at 02:15 AM
- **Backup List**: Weekly on Monday at 08:00 AM

## Manual Backup Commands

### Create a Backup
```bash
php artisan backup:run
```

### List Available Backups
```bash
php artisan backup:list
```

### Clean Old Backups
```bash
php artisan backup:clean
```

## Restore Process

### Using Laravel Backup (if restore command is available)
```bash
php artisan backup:restore
```

### Manual Restore Process

1. **Stop the application** to prevent data corruption
2. **Restore Database**:
   ```bash
   # Extract the backup archive
   tar -xzf backup-file.tar.gz
   
   # Import the database
   mysql -u username -p database_name < database-dump.sql
   ```

3. **Restore Storage Files**:
   ```bash
   # Copy storage files back
   cp -r storage-backup/* storage/app/
   ```

4. **Set proper permissions**:
   ```bash
   chown -R www-data:www-data storage/
   chmod -R 755 storage/
   ```

5. **Clear caches**:
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

6. **Start the application**

## Backup Storage

Backups are stored in the configured disk (default: `local`). The backup includes:
- Database dump (MySQL)
- Storage files (`storage/app` directory)
- Configuration files

## Monitoring

- Check backup status in logs: `storage/logs/laravel.log`
- Monitor backup health via the weekly backup list command
- Set up email notifications for backup failures

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure the web server has write access to storage directories
2. **Database Connection Failed**: Verify database credentials in `.env`
3. **Storage Full**: Monitor disk space and clean old backups regularly

### Recovery Testing

It's recommended to test restore procedures regularly:
1. Create a test environment
2. Perform a restore from a recent backup
3. Verify application functionality
4. Document any issues and solutions
