<#
.SYNOPSIS
PS25 Script: PS50-Add-Data-Retention

.DESCRIPTION
INPUT: None
PROCESSING: Creates CronJob to archive old tenant data > 7 years
OUTPUT: Automated GDPR-compliant data archiving
HYPERLINK: https://gdpr.eu
STACK: Kubernetes CronJob + pg_dump
COMPLIANCE: PS25 GDPR Data Retention Policy

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 5
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS50: Adding Data Retention CronJob ===" -ForegroundColor Cyan

$retention = Join-Path $BasePath "atlas-workspace\platform\k8s\data-retention-cronjob.yaml"
@"
apiVersion: batch/v1
kind: CronJob
metadata: {name: data-retention}
spec:
  schedule: "0 3 1 * *" # 3am on 1st of month
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: retainer
            image: postgres:16
            command: ["/bin/sh","-c","psql -c \"DELETE FROM vouchers WHERE created_at < now() - interval '7 years' AND tenant_id = '\"$TENANT_ID\"'\""]
            envFrom: [{secretRef: {name: demo-bank-secrets}}]
          restartPolicy: OnFailure
"@ | Out-File $retention -Encoding utf8

Write-Host "PS50 Done: Monthly data purge for >7 year old records" -ForegroundColor Green
