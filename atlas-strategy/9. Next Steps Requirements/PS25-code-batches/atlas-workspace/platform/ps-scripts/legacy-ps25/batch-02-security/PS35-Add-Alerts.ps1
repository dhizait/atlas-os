<#
.SYNOPSIS
PS25 Script: PS35-Add-Alerts

.DESCRIPTION
INPUT: None
PROCESSING: Creates alerts.yml for Prometheus + grafana-dashboard.json
OUTPUT: Alert on 5xx errors per tenant + Grafana dashboard for vouchers/min
HYPERLINK: https://prometheus.io/docs/practices/rules/
STACK: Prometheus + Grafana
COMPLIANCE: PS25 Observability SLO

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 2
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS35: Adding Prometheus Alert + Grafana Dashboard ===" -ForegroundColor Cyan

$configDir = Join-Path $BasePath "atlas-workspace\platform\configs"
New-Item -ItemType Directory -Force $configDir | Out-Null

$alert = Join-Path $configDir "alerts.yml"
@"
groups:
- name: demo-bank
  rules:
    - alert: HighErrorRate
    expr: rate(http_server_requests_seconds_count{status=~"5.."}[5m]) > 0.05
    labels: {severity: critical}
    annotations: {summary: "High 5xx errors for tenant {{ `$labels.tenant_id }}"}
"@ | Out-File -FilePath $alert -Encoding utf8

$dashboard = Join-Path $configDir "grafana-dashboard.json"
@"
{"dashboard":{"title":"Demo Bank Multi-Tenant","panels":[
{"title":"Vouchers/min by Tenant","type":"timeseries","targets":[{"expr":"sum(rate(vouchers_created_total[1m])) by (tenant_id)"}]}]}}
"@ | Out-File -FilePath $dashboard -Encoding utf8

Write-Host "PS35 Done: Import grafana-dashboard.json in Grafana" -ForegroundColor Green
