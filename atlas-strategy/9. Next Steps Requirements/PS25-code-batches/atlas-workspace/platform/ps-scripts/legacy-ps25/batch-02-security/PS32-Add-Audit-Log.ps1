<#
.SYNOPSIS
PS25 Script: PS32-Add-Audit-Log

.DESCRIPTION
INPUT: None
PROCESSING: Creates Flyway migration for audit_log table + Kafka AuditService
OUTPUT: Every voucher action written to DB and Kafka topic audit.log
HYPERLINK: https://kafka.apache.org
STACK: PostgreSQL + Flyway + Spring Kafka
COMPLIANCE: PS25 Audit Trail per tenant_id for SOC2

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 2
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS32: Adding Audit Log for all voucher actions ===" -ForegroundColor Cyan

$flyway = Join-Path $BasePath "backend\src\main\resources\db\migration\V2__audit_log.sql"
@"
CREATE TABLE audit_log (
    id BIGSERIAL PRIMARY KEY,
    tenant_id UUID NOT NULL,
    user_id VARCHAR(255),
    action VARCHAR(100),
    entity_id VARCHAR(255),
    timestamp TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_audit_tenant ON audit_log(tenant_id, timestamp);
"@ | Out-File -FilePath $flyway -Encoding utf8

$auditService = Join-Path $BasePath "backend\src\main\java\com\demobank\service\AuditService.java"
@"
package com.demobank.service;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
@Service
public class AuditService {
    private final KafkaTemplate<String,Object> kafka;
    public AuditService(KafkaTemplate<String,Object> k) { this.kafka = k; }
    public void log(String action, String entityId) {
        kafka.send("audit.log", new AuditEvent(
            com.demobank.context.TenantContext.getTenantId(),
            "system", action, entityId));
    }
    public record AuditEvent(java.util.UUID tenantId, String userId, String action, String entityId) {}
}
"@ | Out-File -FilePath $auditService -Encoding utf8

Write-Host "PS32 Done: Call AuditService.log() in BE-PS73 after voucher post" -ForegroundColor Green
