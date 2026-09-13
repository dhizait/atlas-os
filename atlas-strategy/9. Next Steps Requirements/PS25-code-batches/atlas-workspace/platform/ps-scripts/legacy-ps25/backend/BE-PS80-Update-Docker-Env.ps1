<#
.SYNOPSIS
PS25 Script: BE-PS80-Update-Docker-Env

.DESCRIPTION
INPUT: docker-compose.yml
PROCESSING: Adds SPRING_DATASOURCE_URL, PS25_TENANT_MODE env
OUTPUT: Updated docker-compose.yml
HYPERLINK: https://docs.docker.com/compose
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5 + Docker Compose
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 7
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS80-Update-Docker-Env.ps1
# PURPOSE: Creates docker-compose and builds container
# FILE: BE-PS80-Update-Docker-Env.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [string]$DefaultTenantId = "TENANT001",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$composeFile = Join-Path $BeRoot "docker-compose.yml"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS80: $Msg" -ForegroundColor $color
}

Write-Log "PS80: Adding PS25 env vars to docker-compose" "INFO"
if (-not (Test-Path $composeFile)) {
  Write-Log "docker-compose.yml not found. Run PS74 first" "ERROR"
  exit 1
}

if ($DryRun) { Write-Host "[PS80 DRY RUN] Would update app service env in $composeFile"; exit 0 }

$content = Get-Content $composeFile -Raw

# Add environment block for Spring Boot
if ($content -match "environment:") {
    $newEnv = @"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/corebank
      PS25_TENANT_MODE: enabled
      DEFAULT_TENANT_ID: $DefaultTenantId
"@
    $content = $content -replace '(?ms)(environment:)(.*?)(?=\n [a-z]|$)', $newEnv
} else {
    $content = $content -replace "(app:\s*\n)", "`$1 environment:`n SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/corebank`n PS25_TENANT_MODE: enabled`n DEFAULT_TENANT_ID: $DefaultTenantId`n"
}

$content | Set-Content $composeFile -Encoding UTF8

Write-Log "PS80 Complete: Docker env updated for tenant enforcement" "SUCCESS"
Write-Log "PS25_TENANT_MODE=enabled, DEFAULT_TENANT_ID=$DefaultTenantId" "INFO"; exit 0
