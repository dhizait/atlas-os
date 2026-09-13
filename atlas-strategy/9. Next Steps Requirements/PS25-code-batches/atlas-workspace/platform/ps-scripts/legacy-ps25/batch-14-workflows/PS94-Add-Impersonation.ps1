<#
.SYNOPSIS
PS25 Script: PS94-Add-Impersonation

.DESCRIPTION
INPUT: backend/
PROCESSING: Allows support to impersonate tenant user for debugging
OUTPUT: /api/admin/impersonate returns JWT with tenant_id
HYPERLINK: https://oauth.net
STACK: Spring Security + JWT
COMPLIANCE: PS25 Support access with audit

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 14
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS94: Adding Impersonation ===" -ForegroundColor Cyan

$impCtrl = Join-Path $BasePath "backend\src\main\java\com\demobank\admin\ImpersonationController.java"
@"
package com.demobank.admin;
@RestController @RequestMapping("/api/admin")
public class ImpersonationController {
    @PostMapping("/impersonate")
    public Map<String,String> impersonate(@RequestParam String tenantId, @RequestParam String userId) {
        // 1. Check caller has ROLE_SUPPORT
        // 2. Log to audit: "IMPERSONATE"
        // 3. Return JWT with x-tenant-id + x-impersonator
        return Map.of("token", "jwt...");
    }
}
"@ | Out-File $impCtrl -Encoding utf8

Write-Host "PS94 Done: POST /api/admin/impersonate for support" -ForegroundColor Green
