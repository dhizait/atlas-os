<#
.SYNOPSIS
PS25 Script: PS49-Add-Materialized-Views

.DESCRIPTION
INPUT: Postgres DB
PROCESSING: Creates Flyway migration for tenant materialized views
OUTPUT: Fast tenant dashboards without scanning full table
HYPERLINK: https://www.postgresql.org/docs/current/rules-materializedviews.html
STACK: PostgreSQL + Flyway
COMPLIANCE: PS25 Performance per tenant

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 5
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS49: Adding Materialized Views ===" -ForegroundColor Cyan

$mvSql = Join-Path $BasePath "backend\src\main\resources\db\migration\V3__materialized_views.sql"
@"
CREATE MATERIALIZED VIEW mv_tenant_voucher_summary AS
SELECT tenant_id, DATE(created_at) as day, COUNT(*) as total, SUM(amount) as sum_amount
FROM vouchers GROUP BY 1,2;

CREATE INDEX ON mv_tenant_voucher_summary(tenant_id, day);

-- Refresh job every 15 min
SELECT cron.schedule('refresh-mv', '*/15 * * * *', 'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_tenant_voucher_summary');
"@ | Out-File $mvSql -Encoding utf8

Write-Host "PS49 Done: MV created. Query with WHERE tenant_id =?" -ForegroundColor Green
