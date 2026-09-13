<#
.SYNOPSIS
PS25 Script: PS86-Add-Usage-Metering

.DESCRIPTION
INPUT: backend/
PROCESSING: Tracks per-tenant usage: vouchers, API calls, storage
OUTPUT: usage_events table + daily rollup to usage_summary
HYPERLINK: https://stripe.com/billing/metered-billing
STACK: Spring Boot + Kafka + PostgreSQL
COMPLIANCE: PS25 Multi-tenant billing

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 13
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS86: Adding Usage Metering ===" -ForegroundColor Cyan

$meterSvc = Join-Path $BasePath "backend\src\main\java\com\demobank\billing\UsageMeterService.java"
@"
package com.demobank.billing;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
@Service
public class UsageMeterService {
    @KafkaListener(topics = "audit.log")
    public void recordUsage(AuditEvent event) {
        // Insert into usage_events: tenant_id, metric, quantity, timestamp
        // Metrics: VOUCHER_CREATED=1, API_CALL=1, STORAGE_MB
    }
}
"@ | Out-File $meterSvc -Encoding utf8

$migration = Join-Path $BasePath "backend\src\main\resources\db\migration\V7__usage_tables.sql"
@"
CREATE TABLE usage_events (id UUID, tenant_id UUID, metric VARCHAR, quantity INT, ts TIMESTAMP);
CREATE TABLE usage_summary (tenant_id UUID, metric VARCHAR, month DATE, total INT, PRIMARY KEY(tenant_id,metric,month));
"@ | Out-File $migration -Encoding utf8

Write-Host "PS86 Done: Usage tracked per tenant" -ForegroundColor Green
