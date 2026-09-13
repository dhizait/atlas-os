<#
.SYNOPSIS
PS25 Script: PS46-Add-Debezium-CDC

.DESCRIPTION
INPUT: docker-compose.yml
PROCESSING: Adds Debezium + Kafka Connect for Postgres CDC
OUTPUT: All INSERT/UPDATE/DELETE on vouchers table streamed to Kafka topic db.vouchers
HYPERLINK: https://debezium.io
STACK: Debezium + Kafka Connect + PostgreSQL
COMPLIANCE: PS25 Event-driven architecture per tenant_id

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 5
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS46: Adding Debezium CDC ===" -ForegroundColor Cyan

$cdcCompose = Join-Path $BasePath "docker-compose-cdc.yml"
@"
version: '3.8'
services:
  connect:
    image: debezium/connect:2.5
    ports: ["8083:8083"]
    environment:
      CONNECT_BOOTSTRAP_SERVERS: kafka:9092
      CONNECT_GROUP_ID: 1
      CONNECT_CONFIG_STORAGE_TOPIC: connect_configs
      CONNECT_OFFSET_STORAGE_TOPIC: connect_offsets
    depends_on: [kafka, postgres]
  postgres:
    environment:
      POSTGRES_DB: demobank
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
"@ | Out-File $cdcCompose -Encoding utf8

$connector = Join-Path $BasePath "atlas-workspace\platform\configs\debezium-connector.json"
@"
{
  "name": "postgres-connector",
  "config": {
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "plugin.name": "pgoutput",
    "database.hostname": "postgres",
    "database.port": "5432",
    "database.user": "postgres",
    "database.password": "postgres",
    "database.dbname": "demobank",
    "table.include.list": "public.vouchers,public.audit_log",
    "topic.prefix": "db"
  }
}
"@ | Out-File $connector -Encoding utf8

Write-Host "PS46 Done: Run 'curl -X POST http://localhost:8083/connectors -d @debezium-connector.json'" -ForegroundColor Green
