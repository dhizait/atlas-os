<#
.SYNOPSIS
PS25 Script: FE-PS50-Docker-Run

.DESCRIPTION
INPUT: src/
PROCESSING: ESLint + tsc + `docker compose up -d`
OUTPUT: FE running at :3000
HYPERLINK:
STACK: React 18 + Vite + TypeScript + Docker
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 2
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\frontend\FE-PS50-Docker-Run.ps1
# PURPOSE: Creates docker-compose and builds container
# FILE: FE-PS50-Docker-Run.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$feRoot = Join-Path $BasePath "frontend"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; ERROR="Red"; WARN="Yellow"}[$Level]
  Write-Host "[$time] [$Level] PS50: $Msg" -ForegroundColor $color
}

if (-not (Test-Path $feRoot)) { Write-Log "FE folder not found: $feRoot" "ERROR"; exit 1 }
Set-Location $feRoot

if ($DryRun) { Write-Host "[PS50 DRY RUN] Would run lint, typecheck and docker compose up"; exit 0 }

Write-Log "Running lint + typecheck pre-flight..." "INFO"
npx eslint. --ext.ts,.tsx --max-warnings 0
if ($LASTEXITCODE -ne 0) { Write-Log "ESLint errors found" "ERROR"; exit 1 }

npx tsc --noEmit
if ($LASTEXITCODE -ne 0) { Write-Log "TypeScript errors found" "ERROR"; exit 1 }

Write-Log "Starting docker compose stack..." "INFO"
docker compose up -d
if ($LASTEXITCODE -ne 0) { Write-Log "Docker compose up failed" "ERROR"; exit 1 }

Start-Sleep 5
Write-Log "PS50 Complete: FE running at http://localhost:3000" "SUCCESS"; exit 0
