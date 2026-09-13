<#
.SYNOPSIS
PS25 Script: BE-PS67-Update-Migration

.DESCRIPTION
INPUT: existing tables
PROCESSING: Creates Flyway backfill migration to set NOT NULL
OUTPUT: V__backfill_tenant_id.sql
HYPERLINK: https://flywaydb.org
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 5
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS67-Update-Migration.ps1
# PURPOSE: Handles Flyway/Liquibase migration files
# FILE: BE-PS67-Update-Migration.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$migrationDir = Join-Path $BeRoot "src\main\resources\db\migration"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$migrationFile = Join-Path $migrationDir "V${timestamp}__backfill_tenant_id.sql"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"; $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS67: $Msg" -ForegroundColor $color
}

Write-Log "Creating Flyway migration for tenant_id backfill" "INFO"
if ($DryRun) { Write-Host "[PS67 DRY RUN] Would create $migrationFile"; exit 0 }

New-Item -ItemType Directory -Path $migrationDir -Force | Out-Null

@"
-- PS25: Backfill existing rows with default tenant then make NOT NULL
UPDATE vouchers SET tenant_id = gen_random_uuid() WHERE tenant_id IS NULL;
UPDATE transactions SET tenant_id = gen_random_uuid() WHERE tenant_id IS NULL;
UPDATE accounts SET tenant_id = gen_random_uuid() WHERE tenant_id IS NULL;

ALTER TABLE vouchers ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE transactions ALTER COLUMN tenant_id SET NOT NULL;
ALTER TABLE accounts ALTER COLUMN tenant_id SET NOT NULL;
"@ | Set-Content -Path $migrationFile -Encoding UTF8

Write-Log "PS67 Complete: Flyway migration created at $migrationFile" "SUCCESS"; exit 0
