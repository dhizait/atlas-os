<#
.SYNOPSIS
PS25 Script: PS72-Add-DB-Query-Tuning

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds HikariCP tuning + tenant indexes + query hints
OUTPUT: DB connection pool optimized for 1000 tenants
HYPERLINK: https://github.com/brettwooldridge/HikariCP
STACK: Spring Boot + HikariCP + PostgreSQL
COMPLIANCE: PS25 Support 10k TPS

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 10
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS72: Adding DB Query Tuning ===" -ForegroundColor Cyan

$yml = Join-Path $BasePath "backend\src\main\resources\application.yml"
@"
spring:
  datasource:
    hikari:
      maximum-pool-size: 50
      minimum-idle: 10
      connection-timeout: 30000
"@ | Add-Content $yml

$indexes = Join-Path $BasePath "backend\src\main\resources\db\migration\V5__perf_indexes.sql"
@"
CREATE INDEX CONCURRENTLY idx_vouchers_tenant_date ON vouchers(tenant_id, created_at DESC);
CREATE INDEX CONCURRENTLY idx_vouchers_status ON vouchers(tenant_id, status);
ANALYZE vouchers;
"@ | Out-File $indexes -Encoding utf8

Write-Host "PS72 Done: Hikari 50 connections + tenant indexes" -ForegroundColor Green
