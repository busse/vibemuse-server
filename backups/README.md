# VibeMUSE Database Backups

This directory contains database backups for the VibeMUSE system.

## Backup Files

Backup files are named with the format: `vibemuse_backup_YYYYMMDD_HHMMSS.sql`

## Creating Backups

Use the database management script:

```bash
./scripts/db-manager.sh backup
```

## Restoring Backups

To restore from a backup:

```bash
./scripts/db-manager.sh restore backups/vibemuse_backup_YYYYMMDD_HHMMSS.sql
```

## Backup Schedule

In production, consider setting up automated backups:

- **Daily**: Full database backup
- **Weekly**: Archive backup with longer retention
- **Before Major Updates**: Safety backup

## Security Note

Backup files may contain sensitive data. Ensure proper security measures:

- Encrypt backup files in production
- Restrict access to backup directory
- Regularly test backup restoration procedures
- Store critical backups off-site

## Retention Policy

- **Development**: Keep last 7 days
- **Production**: Keep last 30 days + monthly archives
- **Critical**: Keep major milestone backups indefinitely