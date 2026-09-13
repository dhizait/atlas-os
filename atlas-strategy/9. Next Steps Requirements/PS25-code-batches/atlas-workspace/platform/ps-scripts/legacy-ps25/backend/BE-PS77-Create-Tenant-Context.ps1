<#
.SYNOPSIS
PS25 Script: BE-PS77-Create-Tenant-Context

.DESCRIPTION
INPUT: N/A
PROCESSING: Verifies TenantContext.java exists
OUTPUT: TenantContext.java
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 7
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS77-Create-Tenant-Context.ps1
# PURPOSE: Implements multi-tenancy context and isolation
# FILE: BE-PS77-Create-Tenant-Context.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$contextPath = Join-Path $BeRoot "src\main\java\com\demobank\config\TenantContext.java"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"; $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS77: $Msg" -ForegroundColor $color
}

Write-Log "PS77: Verifying TenantContext exists" "INFO"
if ($DryRun) { Write-Host "[PS77 DRY RUN] Would verify $contextPath"; exit 0 }

# PS77 is alias check for PS68. Ensure file exists
if (-not (Test-Path $contextPath)) {
    New-Item -ItemType Directory -Path (Split-Path $contextPath) -Force | Out-Null
    @'
package com.demobank.config;

import java.util.UUID;

public class TenantContext {
    private static final ThreadLocal<UUID> CURRENT_TENANT = new ThreadLocal<>();

    public static void setTenantId(UUID tenantId) { CURRENT_TENANT.set(tenantId); }
    public static UUID getTenantId() { return CURRENT_TENANT.get(); }
    public static void clear() { CURRENT_TENANT.remove(); }
}
'@ | Set-Content -Path $contextPath -Encoding UTF8
    Write-Log "Created: TenantContext.java" "SUCCESS"
} else {
    Write-Log "TenantContext.java already exists from PS68" "SUCCESS"
}
Write-Log "PS77 Complete: TenantContext verified" "SUCCESS"; exit 0
