<#
.SYNOPSIS
PS25 Script: BE-PS66-Final-Smoke-Test

.DESCRIPTION
INPUT: pom.xml
PROCESSING: Runs `mvn clean test` full suite
OUTPUT: Test results + exit code
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS66-Final-Smoke-Test.ps1
# PURPOSE: Runs unit/integration tests for tenant isolation
# FILE: BE-PS66-Final-Smoke-Test.ps1
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
  Write-Host "[$time] [$Level] PS66: $Msg" -ForegroundColor $color
}

Write-Host "================================================" -ForegroundColor Magenta
Write-Host " PS66: Final Smoke Test" -ForegroundColor Magenta
Write-Host " Running mvn test for PS25 verification" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta

if ($DryRun) { Write-Host "[PS66 DRY RUN] Would run 'mvn test' in $BeRoot"; exit 0 }

Push-Location $BeRoot
try {
  if (-not (Test-Path "pom.xml")) { Write-Log "pom.xml not found. Run PS59 first" "WARN"; exit 1 }

  Write-Log "Running: mvn clean test" "INFO"
  mvn clean test
  if ($LASTEXITCODE -ne 0) { throw "mvn test failed with exit code $LASTEXITCODE" }

  Write-Log "PS66 Complete: All JUnit tests passed" "SUCCESS"
  Write-Log "PS25 IMPLEMENTATION VERIFIED" "SUCCESS"; exit 0
}
catch {
  Write-Log "PS66 Error: Tests failed - $($_.Exception.Message)" "ERROR"; exit 1
}
finally { Pop-Location }
