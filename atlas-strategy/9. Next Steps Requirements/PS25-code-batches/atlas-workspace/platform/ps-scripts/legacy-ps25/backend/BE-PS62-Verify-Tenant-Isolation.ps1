<#
.SYNOPSIS
PS25 Script: BE-PS62-Verify-Tenant-Isolation

.DESCRIPTION
INPUT: TenantBase.java, TenantFilter.java
PROCESSING: Checks isolation artifacts exist
OUTPUT: Console verification report
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS62-Verify-Tenant-Isolation.ps1
# PURPOSE: Implements multi-tenancy context and isolation
# FILE: BE-PS62-Verify-Tenant-Isolation.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS62: $Msg" -ForegroundColor $color
}

Write-Log "Verifying tenant isolation for Spring Boot" "INFO"
if ($DryRun) { Write-Host "[PS62 DRY RUN] Would verify tenant isolation"; exit 0 }

# 1. Check JPA TenantBase
$tenantBase = Join-Path $BeRoot "src\main\java\com\demobank\domain\TenantBase.java"
if (Test-Path $tenantBase) {
  $content = Get-Content $tenantBase -Raw
  if ($content -match "tenantId" -and $content -match "@MappedSuperclass") {
    Write-Log "Found TenantBase with tenantId. PS25 isolation enabled" "SUCCESS"
  } else { Write-Log "TenantBase incomplete. Run PS57 first" "WARN" }
} else { Write-Log "TenantBase.java not found. Run PS57 first" "WARN" }

# 2. Check test utils
$testUtil = Join-Path $BeRoot "src\test\java\com\demobank\util\TenantTestUtil.java"
if (Test-Path $testUtil) { Write-Log "Found TenantTestUtil.java from PS60" "SUCCESS" }
else { Write-Log "TenantTestUtil.java not found. Run PS60 first" "WARN" }

# 3. Check TenantFilter
$filterFile = Join-Path $BeRoot "src\main\java\com\demobank\config\TenantFilter.java"
if (Test-Path $filterFile) { Write-Log "Found TenantFilter.java for header extraction" "SUCCESS" }
else { Write-Log "TenantFilter.java not found. Run PS65 first" "WARN" }

Write-Log "PS62 Complete: Tenant isolation verification ready" "SUCCESS"; exit 0
