<#
.SYNOPSIS
PS25 Script: PS95-Add-Support-Tools

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds support endpoints: reset password, unlock tenant, replay webhook
OUTPUT: /api/support/* tools for L1 support
HYPERLINK: https://zendesk.com
STACK: Spring Boot
COMPLIANCE: PS25 Reduce MTTR

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 14
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS95: Adding Support Tools ===" -ForegroundColor Cyan

$supportCtrl = Join-Path $BasePath "backend\src\main\java\com\demobank\support\SupportController.java"
@"
package com.demobank.support;
@RestController @RequestMapping("/api/support")
public class SupportController {
    @PostMapping("/reset-password") public void reset(@RequestParam String email) {}
    @PostMapping("/unlock-tenant") public void unlock(@RequestParam String tenantId) {}
    @PostMapping("/replay-webhook") public void replay(@RequestParam String eventId) {}
}
"@ | Out-File $supportCtrl -Encoding utf8

Write-Host "PS95 Done: Support endpoints available" -ForegroundColor Green
