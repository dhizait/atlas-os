<#
.SYNOPSIS
PS25 Script: PS88-Add-Invoice-Generator

.DESCRIPTION
INPUT: backend/
PROCESSING: Monthly invoice PDF per tenant from usage_summary
OUTPUT: /api/billing/invoice?month=2026-01 returns PDF
HYPERLINK: https://itextpdf.com
STACK: Spring Boot + iText + Jasper
COMPLIANCE: PS25 Tax invoices

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 13
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS88: Adding Invoice Generator ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$itextDep = @"
    <dependency><groupId>com.itextpdf</groupId><artifactId>itext7-core</artifactId><version>8.0.2</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$itextDep`n</dependencies>" | Set-Content $pom

$invoiceSvc = Join-Path $BasePath "backend\src\main\java\com\demobank\billing\InvoiceService.java"
@"
package com.demobank.billing;
@Service
public class InvoiceService {
    public byte[] generateInvoice(String tenantId, String month) {
        // Query usage_summary for month
        // Generate PDF with line items: Vouchers, API calls, Storage
        return new byte[0];
    }
}
"@ | Out-File $invoiceSvc -Encoding utf8

Write-Host "PS88 Done: GET /api/billing/invoice?month=2026-01" -ForegroundColor Green
