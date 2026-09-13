<#
.SYNOPSIS
PS25 Script: BE-PS64-Run-Tenant-Tests

.DESCRIPTION
INPUT: pom.xml
PROCESSING: Runs `mvn test -Dtest=TenantIsolationTest`
OUTPUT: Test results
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS64-Run-Tenant-Tests.ps1
# PURPOSE: Implements multi-tenancy context and isolation
# FILE: BE-PS64-Run-Tenant-Tests.ps1
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
  Write-Host "[$time] [$Level] PS64: $Msg" -ForegroundColor $color
}

Write-Log "Running tenant isolation tests via Maven" "INFO"
if ($DryRun) { Write-Host "[PS64 DRY RUN] Would run mvn test for tenant isolation"; exit 0 }

Push-Location $BeRoot
try {
  if (-not (Test-Path "pom.xml")) { Write-Log "pom.xml not found. Run PS59 first" "WARN"; exit 1 }

  Write-Log "Running: mvn test -Dtest=TenantIsolationTest" "INFO"
  mvn test -Dtest="TenantIsolationTest"
  if ($LASTEXITCODE -ne 0) { throw "mvn test failed with exit code $LASTEXITCODE" }

  Write-Log "PS64 Complete: Tenant isolation tests passed" "SUCCESS"; exit 0
}
catch {
  Write-Log "PS64 Error: Tests failed - $($_.Exception.Message)" "ERROR"; exit 1
}
finally { Pop-Location }
