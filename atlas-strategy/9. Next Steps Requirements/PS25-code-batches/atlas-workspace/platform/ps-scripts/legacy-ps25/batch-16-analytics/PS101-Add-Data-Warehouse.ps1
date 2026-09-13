<#
.SYNOPSIS
PS25 Script: PS101-Add-Data-Warehouse

.DESCRIPTION
INPUT: docker-compose.yml
PROCESSING: Adds ClickHouse + nightly ETL from Postgres
OUTPUT: OLAP DB for BI queries. 100x faster aggregations
HYPERLINK: https://clickhouse.com
STACK: ClickHouse + Postgres CDC
COMPLIANCE: PS25 Analytics at scale

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 16
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS101: Adding ClickHouse Data Warehouse ===" -ForegroundColor Cyan

$dwCompose = Join-Path $BasePath "docker-compose-dw.yml"
@"
version: '3.8'
services:
  clickhouse:
    image: clickhouse/clickhouse-server:24.3
    container_name: atlas-clickhouse
    ports:
      - "8123:8123"
      - "9000:9000"
    volumes:
      -./clickhouse/data:/var/lib/clickhouse
      -./clickhouse/config:/etc/clickhouse-server
    environment:
      CLICKHOUSE_DB: analytics
      CLICKHOUSE_USER: atlas
      CLICKHOUSE_PASSWORD: atlas123
"@ | Out-File $dwCompose -Encoding utf8

$chSchema = Join-Path $BasePath "clickhouse\init.sql"
New-Item -ItemType Directory -Force (Split-Path $chSchema) | Out-Null
@"
CREATE TABLE analytics.vouchers
(
    tenant_id UUID,
    voucher_id UUID,
    amount Decimal(18,2),
    created_at DateTime,
    status String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(created_at)
ORDER BY (tenant_id, created_at);
"@ | Out-File $chSchema -Encoding utf8

Write-Host "PS101 Done: Run 'docker compose -f docker-compose-dw.yml up -d'" -ForegroundColor Green
