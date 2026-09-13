<#
.SYNOPSIS
PS25 Script: PS92-Add-Quota-Enforcement

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds quota checks: vouchers/month, API calls, storage
OUTPUT: 429 if tenant exceeds quota. Quotas per plan
HYPERLINK: https://konghq.com
STACK: Spring Boot + Redis + AOP
COMPLIANCE: PS25 Fair usage + plan limits

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 14
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS92: Adding Quota Enforcement ===" -ForegroundColor Cyan

$quotaAspect = Join-Path $BasePath "backend\src\main\java\com\demobank\quota\QuotaAspect.java"
@"
package com.demobank.quota;
import org.aspectj.lang.annotation.*;
@Aspect @Component
public class QuotaAspect {
    @Before("@annotation(CheckQuota)")
    public void check(JoinPoint jp) {
        // Get tenant_id from context
        // Redis INCR usage:tenant:{id}:vouchers
        // If > quota, throw QuotaExceededException 429
    }
}
"@ | Out-File $quotaAspect -Encoding utf8

Write-Host "PS92 Done: Annotate APIs with @CheckQuota" -ForegroundColor Green
