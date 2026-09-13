<#
.SYNOPSIS
PS25 Script: PS83-Add-PagerDuty-Integration

.DESCRIPTION
INPUT: alertmanager/
PROCESSING: Routes Prometheus alerts to PagerDuty with tenant_id
OUTPUT: On-call gets alert with runbook link
HYPERLINK: https://www.pagerduty.com
STACK: Alertmanager + PagerDuty Webhook
COMPLIANCE: PS25 24/7 on-call

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 12
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS83: Adding PagerDuty Integration ===" -ForegroundColor Cyan

$alertCfg = Join-Path $BasePath "alertmanager\alertmanager.yml"
@"
route:
  receiver: 'pagerduty'
receivers:
- name: 'pagerduty'
  pagerduty_configs:
    - service_key: 'YOUR_PD_INTEGRATION_KEY'
    description: '{{.GroupLabels.alertname }} - Tenant: {{.CommonLabels.tenant_id }}'
    details:
      runbook: 'https://wiki.demo-bank.com/runbooks/{{.CommonLabels.alertname }}'
"@ | Out-File $alertCfg -Encoding utf8

Write-Host "PS83 Done: Restart alertmanager. Alerts now page on-call" -ForegroundColor Green
