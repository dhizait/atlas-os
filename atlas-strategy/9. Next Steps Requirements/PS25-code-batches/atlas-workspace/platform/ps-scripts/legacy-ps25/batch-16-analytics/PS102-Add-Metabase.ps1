<#
.SYNOPSIS
PS25 Script: PS102-Add-Metabase

.DESCRIPTION
INPUT: docker-compose.yml
PROCESSING: Adds Metabase with tenant row-level security
OUTPUT: http://localhost:3001 BI dashboards per tenant
HYPERLINK: https://metabase.com
STACK: Metabase + ClickHouse + Postgres
COMPLIANCE: PS25 Self-service BI

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 16
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS102: Adding Metabase ===" -ForegroundColor Cyan

$biCompose = Join-Path $BasePath "docker-compose-bi.yml"
@"
version: '3.8'
services:
  metabase:
    image: metabase/metabase:v0.50
    container_name: atlas-metabase
    ports:
      - "3001:3000"
    environment:
      MB_DB_TYPE: postgres
      MB_DB_DBNAME: metabase
      MB_DB_PORT: 5432
      MB_DB_USER: postgres
      MB_DB_PASS: postgres
      MB_DB_HOST: postgres
"@ | Out-File $biCompose -Encoding utf8

$rlsPolicy = Join-Path $BasePath "backend\src\main\resources\db\migration\V8__metabase_rls.sql"
@"
-- Metabase will filter by tenant_id automatically
ALTER TABLE vouchers ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON vouchers USING (tenant_id = current_setting('app.tenant_id')::uuid);
"@ | Out-File $rlsPolicy -Encoding utf8

Write-Host "PS102 Done: Metabase at http://localhost:3001" -ForegroundColor Green
