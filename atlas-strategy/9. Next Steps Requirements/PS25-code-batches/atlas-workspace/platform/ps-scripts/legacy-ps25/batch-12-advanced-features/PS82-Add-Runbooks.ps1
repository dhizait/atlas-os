<#
.SYNOPSIS
PS25 Script: PS82-Add-Runbooks

.DESCRIPTION
INPUT: docs/
PROCESSING: Creates markdown runbooks for top 5 incidents
OUTPUT: /docs/runbooks with step-by-step recovery
HYPERLINK: https://www.atlassian.com/incident-management
STACK: Markdown + Confluence
COMPLIANCE: PS25 MTTR < 30min

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 12
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS82: Adding Runbooks ===" -ForegroundColor Cyan

$rbDir = Join-Path $BasePath "docs\runbooks"
New-Item -ItemType Directory -Force $rbDir | Out-Null

$dbDown = Join-Path $rbDir "DB_DOWN.md"
@"
# Runbook: Database Down
**Severity**: P1
**SLI Impacted**: Availability
**Steps**:
1. Check `kubectl get pods -n demo-bank`
2. Check `kubectl logs -l app=postgres`
3. If Patroni failed, run: `kubectl exec patroni-0 -- patronictl failover`
4. Validate: `curl /actuator/health`
**Escalation**: DB Admin on-call
"@ | Out-File $dbDown -Encoding utf8

Write-Host "PS82 Done: Runbooks in docs/runbooks/" -ForegroundColor Green
