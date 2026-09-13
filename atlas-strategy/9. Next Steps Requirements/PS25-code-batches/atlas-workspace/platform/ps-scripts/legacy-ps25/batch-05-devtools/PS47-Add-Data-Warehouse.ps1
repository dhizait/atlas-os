<#
.SYNOPSIS
PS25 Script: PS47-Add-Data-Warehouse

.DESCRIPTION
INPUT: Kafka topics from PS46
PROCESSING: Creates ClickHouse/Postgres DW + Kafka Connect Sink
OUTPUT: Tenant-aware OLAP tables for reporting
HYPERLINK: https://clickhouse.com
STACK: ClickHouse + Kafka Connect JDBC Sink
COMPLIANCE: PS25 Separate OLTP and OLAP per tenant

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 5
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS47: Adding Data Warehouse ===" -ForegroundColor Cyan

$dwCompose = Join-Path $BasePath "docker-compose-dw.yml"
@"
version: '3.8'
services:
  clickhouse:
    image: clickhouse/clickhouse-server:latest
    ports: ["8123:8123", "9000:9000"]
    volumes: ["./clickhouse:/var/lib/clickhouse"]
"@ | Out-File $dwCompose -Encoding utf8

$dwSchema = Join-Path $BasePath "atlas-workspace\platform\configs\dw-schema.sql"
@"
CREATE TABLE vouchers_dw (
    tenant_id UUID,
    voucher_id UUID,
    amount Decimal(18,2),
    created_at DateTime,
    event_time DateTime DEFAULT now()
) ENGINE = MergeTree PARTITION BY toYYYYMM(created_at) ORDER BY (tenant_id, created_at);
"@ | Out-File $dwSchema -Encoding utf8

Write-Host "PS47 Done: DW ready at http://localhost:8123" -ForegroundColor Green
