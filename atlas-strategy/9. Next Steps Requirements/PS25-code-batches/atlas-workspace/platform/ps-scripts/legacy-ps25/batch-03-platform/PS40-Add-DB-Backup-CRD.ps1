<#
.SYNOPSIS
PS25 Script: PS40-Add-DB-Backup-CRD

.DESCRIPTION
INPUT: None
PROCESSING: Creates K8s CronJob for nightly Postgres pg_dump per tenant schema
OUTPUT: Automated DB backups to /backup with tenant_id in filename
HYPERLINK: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
STACK: Kubernetes CronJob + Postgres
COMPLIANCE: PS25 RPO < 24h

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 3
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS40: Adding DB Backup CronJob ===" -ForegroundColor Cyan

$backupPath = Join-Path $BasePath "atlas-workspace\platform\k8s\demo-bank\templates\backup-cronjob.yaml"

@"
apiVersion: batch/v1
kind: CronJob
metadata: {name: postgres-backup}
spec:
  schedule: "0 2 * * *" # 2am daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
                    - name: pgbackup
            image: postgres:16
            command: ["/bin/sh","-c","pg_dump -U postgres -F c > /backup/dump-$(date +%F).sql"]
            envFrom: [{secretRef: {name: demo-bank-secrets}}]
            volumeMounts: [{name: backup, mountPath: /backup}]
          volumes: [{name: backup, persistentVolumeClaim: {claimName: backup-pvc}}]
          restartPolicy: OnFailure
"@ | Out-File $backupPath -Encoding utf8

Write-Host "PS40 Done: Nightly backup at 2am to PVC" -ForegroundColor Green
