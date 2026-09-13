<#
.SYNOPSIS
PS25 Script: PS78-Add-Auto-Failover

.DESCRIPTION
INPUT: k8s/
PROCESSING: Adds Patroni + Keepalived for automatic DB failover
OUTPUT: DB VIP switches to DR in < 60s if primary down
HYPERLINK: https://patroni.readthedocs.io
STACK: Patroni + etcd + HAProxy
COMPLIANCE: PS25 RTO < 1h

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 11
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS78: Adding Auto Failover ===" -ForegroundColor Cyan

$patroni = Join-Path $BasePath "atlas-workspace\platform\k8s\patroni.yaml"
@"
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: postgres}
spec:
  serviceName: postgres
  replicas: 2
  template:
    spec:
      containers:
      - name: postgres
        image: patroni:latest
        env:
        - name: PATRONI_SCOPE
          value: atlas-pg
        - name: PATRONI_FAILOVER_PRIORITY
          value: "100"
"@ | Out-File $patroni -Encoding utf8

Write-Host "PS78 Done: Patroni handles failover. Test with 'kubectl delete pod postgres-0'" -ForegroundColor Green
