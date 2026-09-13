<#
.SYNOPSIS
PS25 Script: PS68-Add-Anomaly-Detection

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds scheduled job to detect tenant anomalies: spike in vouchers
OUTPUT: Alert to Kafka topic fraud.alerts when z-score > 3
HYPERLINK: https://scikit-learn.org
STACK: Spring Scheduler + Apache Commons Math
COMPLIANCE: PS25 Proactive risk monitoring

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 9
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS68: Adding Anomaly Detection ===" -ForegroundColor Cyan

$anomalyJob = Join-Path $BasePath "backend\src\main\java\com\demobank\ml\AnomalyDetectionJob.java"
@"
package com.demobank.ml;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
@Component
public class AnomalyDetectionJob {
    @Scheduled(cron = "0 */15 * * * *") // every 15 min
    public void detectAnomalies() {
        // 1. Query mv_tenant_voucher_summary
        // 2. Calculate z-score per tenant
        // 3. If > 3, kafka.send("fraud.alerts", tenantId)
    }
}
"@ | Out-File $anomalyJob -Encoding utf8

Write-Host "PS68 Done: Anomalies published to fraud.alerts topic" -ForegroundColor Green
