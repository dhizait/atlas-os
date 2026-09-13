<#
.SYNOPSIS
PS25 Script: BE-PS58-Add-Migration-Script

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates Flyway V__add_tenant_id_columns.sql
OUTPUT: src/main/resources/db/migration/V*.sql
HYPERLINK: https://flywaydb.org
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 1
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS58-Add-Migration-Script.ps1
# PURPOSE: Handles Flyway/Liquibase migration files
# FILE: BE-PS58-Add-Migration-Script.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$flywayDir = Join-Path $BeRoot "src\main\resources\db\migration"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$migrationFile = Join-Path $flywayDir "V${timestamp}__add_tenant_id_columns.sql"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS58: $Msg" -ForegroundColor $color
}

Write-Log "Creating Flyway migration for tenant_id columns" "INFO"
if (-not (Test-Path $flywayDir)) { New-Item -ItemType Directory -Path $flywayDir -Force | Out-Null }

if ($DryRun) { Write-Host "[PS58 DRY RUN] Would write migration to $migrationFile"; exit 0 }

@"
-- PS25: Add tenant_id columns
ALTER TABLE vouchers ADD COLUMN tenant_id UUID NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE transactions ADD COLUMN tenant_id UUID NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE accounts ADD COLUMN tenant_id UUID NOT NULL DEFAULT gen_random_uuid();

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_vouchers_tenant_id ON vouchers(tenant_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_transactions_tenant_id ON transactions(tenant_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_accounts_tenant_id ON accounts(tenant_id);
"@ | Set-Content $migrationFile -Encoding UTF8

Write-Log "PS58 Complete: Flyway migration created at $migrationFile" "SUCCESS"; exit 0
