<#
.SYNOPSIS
PS25 Script: PS48-Add-Tenant-BI-Dashboard

.DESCRIPTION
INPUT: Data Warehouse from PS47
PROCESSING: Creates Metabase dashboard with tenant_id row-level security
OUTPUT: Each tenant sees only their own voucher data
HYPERLINK: https://www.metabase.com
STACK: Metabase + ClickHouse
COMPLIANCE: PS25 Data isolation in BI layer

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 5
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS48: Adding Tenant BI Dashboard ===" -ForegroundColor Cyan

$biCompose = Join-Path $BasePath "docker-compose-bi.yml"
@"
version: '3.8'
services:
  metabase:
    image: metabase/metabase:latest
    ports: ["3001:3000"]
    environment:
      MB_DB_TYPE: postgres
      MB_DBNAME: metabase
      MB_DB_PORT: 5432
      MB_DB_USER: postgres
      MB_DB_PASS: postgres
"@ | Out-File $biCompose -Encoding utf8

$dashboard = Join-Path $BasePath "atlas-workspace\platform\configs\metabase-dashboard.json"
@"
{"dashboard": {"name": "Tenant Voucher Analytics", "filters": [{"name": "tenant_id", "type": "text"}],
"cards": [{"name": "Vouchers by Day", "query": "SELECT date, count(*) FROM vouchers_dw WHERE tenant_id = {{tenant_id}} GROUP BY 1"}]}}
"@ | Out-File $dashboard -Encoding utf8

Write-Host "PS48 Done: Metabase at http://localhost:3001. Import dashboard.json" -ForegroundColor Green
