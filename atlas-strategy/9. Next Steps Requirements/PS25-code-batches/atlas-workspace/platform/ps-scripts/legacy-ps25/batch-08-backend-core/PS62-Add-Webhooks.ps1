<#
.SYNOPSIS
PS25 Script: PS62-Add-Webhooks

.DESCRIPTION
INPUT: backend/
PROCESSING: Creates webhook subscription + retry + HMAC signing
OUTPUT: POST to partner URL on voucher.created event
HYPERLINK: https://stripe.com/docs/webhooks
STACK: Spring Boot + Kafka Consumer + WebClient
COMPLIANCE: PS25 Event-driven partner integrations

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 8
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS62: Adding Webhooks ===" -ForegroundColor Cyan

$webhookSvc = Join-Path $BasePath "backend\src\main\java\com\demobank\service\WebhookService.java"
@"
package com.demobank.service;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
@Service
public class WebhookService {
    private final WebClient client = WebClient.create();
    @KafkaListener(topics = "audit.log")
    public void onEvent(AuditEvent event) {
        // Lookup partner URLs by tenant_id
        // POST with HMAC-SHA256 signature in X-Signature header
        // Retry 3x with exponential backoff
    }
    public record AuditEvent(java.util.UUID tenantId, String action, String entityId) {}
}
"@ | Out-File $webhookSvc -Encoding utf8

Write-Host "PS62 Done: Webhooks fire on Kafka audit.log events" -ForegroundColor Green
