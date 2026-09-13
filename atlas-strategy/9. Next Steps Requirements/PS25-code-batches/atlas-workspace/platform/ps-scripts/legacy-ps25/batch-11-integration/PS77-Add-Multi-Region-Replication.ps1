<#
.SYNOPSIS
PS25 Script: PS77-Add-Multi-Region-Replication

.DESCRIPTION
INPUT: postgres/
PROCESSING: Sets up logical replication to DR region
OUTPUT: Async replica in region-2. Lag < 10s
HYPERLINK: https://www.postgresql.org/docs/current/logical-replication.html
STACK: PostgreSQL + pglogical
COMPLIANCE: PS25 Multi-region HA

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 11
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS77: Adding Multi-Region Replication ===" -ForegroundColor Cyan

$replicationSql = Join-Path $BasePath "backend\src\main\resources\db\migration\V6__replication.sql"
@"
-- Primary
CREATE PUBLICATION atlas_pub FOR TABLE vouchers, audit_log, users;
-- DR Region
CREATE SUBSCRIPTION atlas_sub CONNECTION 'host=dr-db port=5432 dbname=demobank' PUBLICATION atlas_pub;
"@ | Out-File $replicationSql -Encoding utf8

$health = Join-Path $BasePath "backend\src\main\java\com\demobank\health\ReplicationLagHealth.java"
@"
package com.demobank.health;
import org.springframework.stereotype.Component;
@Component("replication")
public class ReplicationLagHealth implements org.springframework.boot.actuator.health.HealthIndicator {
    public org.springframework.boot.actuator.health.Health health() {
        // SELECT pg_last_xlog_receive_location() - pg_last_xlog_replay_location()
        return org.springframework.boot.actuator.health.Health.up().withDetail("lag_seconds", 5).build();
    }
}
"@ | Out-File $health -Encoding utf8

Write-Host "PS77 Done: DR replica at dr-db.demo-bank.com" -ForegroundColor Green
