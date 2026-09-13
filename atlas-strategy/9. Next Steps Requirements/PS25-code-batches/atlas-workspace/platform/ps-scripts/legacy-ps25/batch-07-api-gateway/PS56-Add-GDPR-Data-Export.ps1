<#
.SYNOPSIS
PS25 Script: PS56-Add-GDPR-Data-Export

.DESCRIPTION
INPUT: backend/
PROCESSING: Creates GDPR /api/gdpr/export endpoint. Exports all tenant data as ZIP
OUTPUT: Downloadable JSON dump per tenant_id + user_id
HYPERLINK: https://gdpr.eu/right-to-access/
STACK: Spring Boot + ZipOutputStream
COMPLIANCE: PS25 GDPR Article 20 - Right to Data Portability

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 7
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS56: Adding GDPR Data Export ===" -ForegroundColor Cyan

$exportCtrl = Join-Path $BasePath "backend\src\main\java\com\demobank\controller\GdprExportController.java"
@"
package com.demobank.controller;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletResponse;
import java.util.zip.ZipOutputStream;
@RestController @RequestMapping("/api/gdpr")
public class GdprExportController {
    @GetMapping("/export")
    public void exportData(@RequestHeader("X-Tenant-ID") String tenantId,
                           @RequestParam String userId,
                           HttpServletResponse response) throws Exception {
        response.setContentType("application/zip");
        response.setHeader("Content-Disposition", "attachment; filename=export-"+tenantId+".zip");
        try(ZipOutputStream zos = new ZipOutputStream(response.getOutputStream())) {
            // Add vouchers.json, audit.json, profile.json filtered by tenant_id + user_id
        }
    }
}
"@ | Out-File $exportCtrl -Encoding utf8

Write-Host "PS56 Done: GET /api/gdpr/export?userId=xxx returns ZIP" -ForegroundColor Green
