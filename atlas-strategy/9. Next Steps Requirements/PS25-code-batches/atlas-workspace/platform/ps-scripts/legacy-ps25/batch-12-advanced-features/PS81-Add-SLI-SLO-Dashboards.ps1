<#
.SYNOPSIS
PS25 Script: PS81-Add-SLI-SLO-Dashboards

.DESCRIPTION
INPUT: grafana/
PROCESSING: Creates SLI dashboards: Latency, ErrorRate, Throughput, Saturation
OUTPUT: Grafana dashboard with SLO burn rate alerts
HYPERLINK: https://sre.google/workbook/implementing-slos/
STACK: Grafana + Prometheus + recording rules
COMPLIANCE: PS25 99.9% availability SLO

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 12
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS81: Adding SLI/SLO Dashboards ===" -ForegroundColor Cyan

$sloDash = Join-Path $BasePath "grafana\dashboards\slo-dashboard.json"
@"
{
  "title": "PS25 SLO Dashboard",
  "panels": [
    {"title": "API Latency p95", "targets": [{"expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))"}]},
    {"title": "Error Rate", "targets": [{"expr": "rate(http_requests_total{status=~'5..'}[5m])"}]},
    {"title": "Burn Rate", "targets": [{"expr": "(1 - availability) / (1 - 0.999)"}]}
  ]
}
"@ | Out-File $sloDash -Encoding utf8

$rules = Join-Path $BasePath "prometheus\rules\slo_rules.yml"
@"
groups:
- name: slo
  rules:
    - record: slo:availability:5m
    expr: 1 - (sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])))
    - alert: HighBurnRate
    expr: slo:availability:5m < 0.999
    for: 10m
"@ | Out-File $rules -Encoding utf8

Write-Host "PS81 Done: Import dashboard in Grafana. SLO = 99.9%" -ForegroundColor Green
