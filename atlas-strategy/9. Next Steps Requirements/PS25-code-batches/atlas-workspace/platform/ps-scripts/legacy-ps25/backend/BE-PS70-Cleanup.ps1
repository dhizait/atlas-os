<#
.SYNOPSIS
PS25 Script: BE-PS70-Cleanup

.DESCRIPTION
INPUT: target/, *.bak
PROCESSING: Removes temp files + runs `mvn clean test`
OUTPUT: Clean workspace
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 5
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS70-Cleanup.ps1
# PURPOSE: Performs core PS25 automation task
# FILE: BE-PS70-Cleanup.ps1
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
  Write-Host "[$time] [$Level] PS70: $Msg" -ForegroundColor $color
}

Write-Log "Cleanup temp files and final mvn test validation" "INFO"
if ($DryRun) { Write-Host "[PS70 DRY RUN] Would remove temp files and run mvn test in $BeRoot"; exit 0 }

Push-Location $BeRoot
Remove-Item *.bak_*, target/*.tmp -ErrorAction SilentlyContinue
Write-Log "Removed temp files" "INFO"

Write-Log "Running mvn clean test" "INFO"
mvn clean test
if ($LASTEXITCODE -ne 0) { throw "Final mvn test validation failed" }

Pop-Location
Write-Log "PS70 Complete: Cleanup done. PS25 fully implemented" "SUCCESS"; exit 0
