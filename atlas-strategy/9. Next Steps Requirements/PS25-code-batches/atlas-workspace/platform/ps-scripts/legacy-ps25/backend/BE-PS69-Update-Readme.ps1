<#
.SYNOPSIS
PS25 Script: BE-PS69-Update-Readme

.DESCRIPTION
INPUT: README.md
PROCESSING: Appends PS25 Spring Boot setup instructions
OUTPUT: Updated README.md
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 5
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS69-Update-Readme.ps1
# PURPOSE: Performs core PS25 automation task
# FILE: BE-PS69-Update-Readme.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$readmeFile = Join-Path $BeRoot "README.md"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS69: $Msg" -ForegroundColor $color
}

Write-Log "Updating README with Spring Boot multi-tenancy setup" "INFO"
if ($DryRun) { Write-Host "[PS69 DRY RUN] Would append to $readmeFile"; exit 0 }

$readmeUpdate = @"

## PS25 Multi-Tenancy Setup - Spring Boot

### 1. Tenant Header
Set `X-Tenant-ID` header on all API requests
Example: `curl -H "X-Tenant-ID: TENANT001" http://localhost:8081/api/v1/vouchers`

### 2. Database Migrations
Run `mvn flyway:migrate` to apply migrations
Migrations located at: `src/main/resources/db/migration/`

### 3. Configuration
`TenantFilter` extracts header and sets `TenantContext` ThreadLocal
`TenantBase` ensures all entities have tenant_id

### 4. Run Tests
Run `mvn test` to verify multi-tenancy isolation
Test files: `src/test/java/com/demobank/service/TenantIsolationTest.java`

### 5. Docker
Build: `docker compose build`
Run: `docker compose up -d`
Backend runs on port 8081
"@

if (Test-Path $readmeFile) { Add-Content -Path $readmeFile -Value $readmeUpdate }
else { Set-Content -Path $readmeFile -Value $readmeUpdate }

Write-Log "PS69 Complete: README updated" "SUCCESS"; exit 0
