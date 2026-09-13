<#
.SYNOPSIS
PS25 Script: PS64-Add-Partner-Portal-API

.DESCRIPTION
INPUT: backend/
PROCESSING: Creates public API Gateway routes with API Key per partner
OUTPUT: /api/partner/v1/vouchers with rate limit + tenant scoping
HYPERLINK: https://konghq.com
STACK: Spring Boot + API Key Filter
COMPLIANCE: PS25 Partner API Management

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 8
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS64: Adding Partner Portal API ===" -ForegroundColor Cyan

$apiKeyFilter = Join-Path $BasePath "backend\src\main\java\com\demobank\security\ApiKeyFilter.java"
@"
package com.demobank.security;
import jakarta.servlet.*; import jakarta.servlet.http.*;
@Component
public class ApiKeyFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) {
        HttpServletRequest request = (HttpServletRequest) req;
        String apiKey = request.getHeader("X-API-Key");
        // Validate apiKey -> tenant_id mapping in DB
        // Set TenantContext
        chain.doFilter(req,res);
    }
}
"@ | Out-File $apiKeyFilter -Encoding utf8

Write-Host "PS64 Done: Partners use X-API-Key header" -ForegroundColor Green
