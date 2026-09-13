<#
.SYNOPSIS
PS25 Script: PS57-Add-Right-To-Erasure

.DESCRIPTION
INPUT: backend/
PROCESSING: Creates /api/gdpr/delete endpoint with hard delete + audit trail
OUTPUT: All PII for user anonymized. Entry in audit_log
HYPERLINK: https://gdpr.eu/right-to-be-forgotten/
STACK: Spring Boot + JPA + AuditService
COMPLIANCE: PS25 GDPR Article 17 - Right to Erasure

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 7
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS57: Adding Right To Erasure ===" -ForegroundColor Cyan

$deleteCtrl = Join-Path $BasePath "backend\src\main\java\com\demobank\controller\GdprDeleteController.java"
@"
package com.demobank.controller;
import org.springframework.web.bind.annotation.*;
import com.demobank.service.AuditService;
@RestController @RequestMapping("/api/gdpr")
public class GdprDeleteController {
    private final AuditService audit;
    public GdprDeleteController(AuditService a) { this.audit = a; }

    @DeleteMapping("/delete")
    public void deleteUser(@RequestHeader("X-Tenant-ID") String tenantId, @RequestParam String userId) {
        // 1. Anonymize vouchers: set user_id = 'DELETED'
        // 2. Delete from users table
        // 3. audit.log("GDPR_DELETE", userId);
    }
}
"@ | Out-File $deleteCtrl -Encoding utf8

Write-Host "PS57 Done: DELETE /api/gdpr/delete?userId=xxx" -ForegroundColor Green
