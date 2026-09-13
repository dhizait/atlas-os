<#
.SYNOPSIS
PS25 Script: BE-PS61-Run-Migration

.DESCRIPTION
INPUT: docker-compose, db
PROCESSING: Runs `mvn flyway:migrate`
OUTPUT: DB migrated with tenant_id columns
HYPERLINK: https://flywaydb.org
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 1
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS61-Run-Migration.ps1
# PURPOSE: Handles Flyway/Liquibase migration files
# FILE: BE-PS61-Run-Migration.ps1
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
  Write-Host "[$time] [$Level] PS61: $Msg" -ForegroundColor $color
}

Write-Log "Running Flyway migration via Maven" "INFO"
if ($DryRun) { Write-Host "[PS61 DRY RUN] Would run: mvn flyway:migrate in $BeRoot"; exit 0 }

Push-Location $BeRoot
try {
  mvn flyway:migrate
  if ($LASTEXITCODE -ne 0) { throw "Flyway migration failed with exit code $LASTEXITCODE" }
  Write-Log "PS61 Complete: Database migrated successfully" "SUCCESS"; exit 0
}
catch {
  Write-Log "PS61 Error: Migration failed - $($_.Exception.Message)" "ERROR"; exit 1
}
finally { Pop-Location }
