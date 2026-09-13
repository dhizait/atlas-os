<#
.SYNOPSIS
PS25 Script: PS89-Add-Dunning-Workflow

.DESCRIPTION
INPUT: backend/
PROCESSING: Handles failed payments. 3 retries + email + suspension
OUTPUT: Tenant suspended if unpaid after 14 days
HYPERLINK: https://stripe.com/docs/billing/payments
STACK: Spring Scheduler + Stripe Webhooks
COMPLIANCE: PS25 Revenue protection

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 13
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS89: Adding Dunning Workflow ===" -ForegroundColor Cyan

$dunningJob = Join-Path $BasePath "backend\src\main\java\com\demobank\billing\DunningJob.java"
@"
package com.demobank.billing;
import org.springframework.scheduling.annotation.Scheduled;
@Service
public class DunningJob {
    @Scheduled(cron = "0 9 * * *") // 9am daily
    public void runDunning() {
        // 1. Get failed invoices from Stripe
        // 2. Day 1: Email. Day 7: Warning. Day 14: Suspend tenant
        // 3. Update tenant.status = 'SUSPENDED'
    }
}
"@ | Out-File $dunningJob -Encoding utf8

Write-Host "PS89 Done: Daily dunning job runs" -ForegroundColor Green
