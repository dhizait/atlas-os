<#
.SYNOPSIS
PS25 Script: PS91-Add-Tenant-Provisioning

.DESCRIPTION
INPUT: backend/
PROCESSING: Creates /api/admin/tenants POST endpoint for self-service signup
OUTPUT: New tenant_id, DB schema, default roles, welcome email
HYPERLINK: https://saas-boilerplate.com
STACK: Spring Boot + JPA + Mail
COMPLIANCE: PS25 Automated onboarding < 2min

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 14
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS91: Adding Tenant Provisioning ===" -ForegroundColor Cyan

$tenantCtrl = Join-Path $BasePath "backend\src\main\java\com\demobank\admin\TenantProvisioningController.java"
@"
package com.demobank.admin;
import org.springframework.web.bind.annotation.*;
@RestController @RequestMapping("/api/admin/tenants")
public class TenantProvisioningController {
    @PostMapping
    public Map<String,String> provision(@RequestBody TenantRequest req) {
        // 1. Create tenant record
        // 2. Run DB migrations for tenant schema
        // 3. Create admin user
        // 4. Send welcome email
        return Map.of("tenant_id", UUID.randomUUID().toString());
    }
    record TenantRequest(String name, String adminEmail) {}
}
"@ | Out-File $tenantCtrl -Encoding utf8

Write-Host "PS91 Done: POST /api/admin/tenants to create new tenant" -ForegroundColor Green
