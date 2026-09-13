<#
.SYNOPSIS
PS25 Script: BE-PS65-Update-API-Docs

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates TenantFilter.java to extract X-Tenant-ID
OUTPUT: src/main/java/com/demobank/config/TenantFilter.java
HYPERLINK: https://www.openapis.org
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS65-Update-API-Docs.ps1
# PURPOSE: Performs core PS25 automation task
# FILE: BE-PS65-Update-API-Docs.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$configDir = Join-Path $BeRoot "src\main\java\com\demobank\config"
$filterFile = Join-Path $configDir "TenantFilter.java"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS65: $Msg" -ForegroundColor $color
}

Write-Log "Updating OpenAPI docs with X-Tenant-ID header" "INFO"
if (-not (Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir -Force | Out-Null }

if ($DryRun) { Write-Host "[PS65 DRY RUN] Would write to $filterFile"; exit 0 }

@'
package com.demobank.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Component;
import java.io.IOException;
import java.util.UUID;

@Component
public class TenantFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String tenantId = httpRequest.getHeader("X-Tenant-ID");
        if (tenantId == null || tenantId.isEmpty()) {
            throw new ServletException("X-Tenant-ID header is required");
        }
        TenantContext.setTenantId(UUID.fromString(tenantId));
        try {
            chain.doFilter(request, response);
        } finally {
            TenantContext.clear();
        }
    }
}
'@ | Set-Content $filterFile -Encoding UTF8

Write-Log "PS65 Complete: TenantFilter added. Add @OpenAPIDefinition with header param for docs" "SUCCESS"; exit 0
