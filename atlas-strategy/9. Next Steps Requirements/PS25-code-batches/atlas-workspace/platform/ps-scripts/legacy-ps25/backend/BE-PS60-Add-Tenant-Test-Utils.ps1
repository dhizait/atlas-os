<#
.SYNOPSIS
PS25 Script: BE-PS60-Add-Tenant-Test-Utils

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates TenantTestUtil.java for JUnit
OUTPUT: src/test/java/com/demobank/util/TenantTestUtil.java
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 1
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS60-Add-Tenant-Test-Utils.ps1
# PURPOSE: Implements multi-tenancy context and isolation
# FILE: BE-PS60-Add-Tenant-Test-Utils.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$testDir = Join-Path $BeRoot "src\test\java\com\demobank\util"
$testFile = Join-Path $testDir "TenantTestUtil.java"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS60: $Msg" -ForegroundColor $color
}

Write-Log "Adding tenant test utilities for JUnit" "INFO"
if (-not (Test-Path $testDir)) { New-Item -ItemType Directory -Path $testDir -Force | Out-Null }

if ($DryRun) { Write-Host "[PS60 DRY RUN] Would write to $testFile"; exit 0 }

@'
package com.demobank.util;

import java.util.UUID;
import org.springframework.http.HttpHeaders;

public class TenantTestUtil {
    public static UUID createTestTenant() { return UUID.randomUUID(); }
    public static HttpHeaders tenantHeaders(UUID tenantId) {
        HttpHeaders headers = new HttpHeaders();
        headers.add("X-Tenant-ID", tenantId.toString());
        return headers;
    }
}
'@ | Set-Content $testFile -Encoding UTF8

Write-Log "PS60 Complete: TenantTestUtil.java added" "SUCCESS"; exit 0
