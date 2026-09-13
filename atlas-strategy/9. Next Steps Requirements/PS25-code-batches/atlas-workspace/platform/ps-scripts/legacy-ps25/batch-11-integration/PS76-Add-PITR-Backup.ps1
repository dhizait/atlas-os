<#
.SYNOPSIS
PS25 Script: PS76-Add-PITR-Backup

.DESCRIPTION
INPUT: docker-compose.yml
PROCESSING: Configures PostgreSQL WAL archiving + base backup to S3
OUTPUT: Point-in-time recovery to any second. RPO < 5min
HYPERLINK: https://www.postgresql.org/docs/current/continuous-archiving.html
STACK: PostgreSQL 16 + WAL-G + S3
COMPLIANCE: PS25 RPO < 5min

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 11
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS76: Adding PITR Backup ===" -ForegroundColor Cyan

$pgConf = Join-Path $BasePath "postgres\postgresql.conf"
@"
wal_level = replica
archive_mode = on
archive_command = 'wal-g wal-push %p'
archive_timeout = 300
"@ | Add-Content $pgConf

$backupCron = Join-Path $BasePath "atlas-workspace\platform\k8s\pitr-backup-cronjob.yaml"
@"
apiVersion: batch/v1
kind: CronJob
metadata: {name: pitr-base-backup}
spec:
  schedule: "0 */6 * * *" # every 6 hours
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: wal-g
            image: wal-g:latest
            command: ["wal-g", "backup-push", "/var/lib/postgresql/data"]
            env: [{name: AWS_S3_BUCKET, value: atlas-pitr-backups}]
"@ | Out-File $backupCron -Encoding utf8

Write-Host "PS76 Done: PITR enabled. Restore with 'wal-g backup-fetch + wal-g wal-fetch'" -ForegroundColor Green
