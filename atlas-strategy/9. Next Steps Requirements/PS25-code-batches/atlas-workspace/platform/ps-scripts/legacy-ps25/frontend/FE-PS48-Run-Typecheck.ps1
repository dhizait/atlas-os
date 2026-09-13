<#
.SYNOPSIS
PS25 Script: FE-PS48-Run-Typecheck

.DESCRIPTION
INPUT: package.json
PROCESSING: Ensures `typecheck` script, runs `tsc --noEmit`
OUTPUT: 0 TS errors
HYPERLINK: https://www.typescriptlang.org
STACK: React 18 + Vite + TypeScript + Docker
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 2
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\frontend\FE-PS48-Run-Typecheck.ps1
# PURPOSE: Runs tsc --noEmit for FE
# FILE: FE-PS48-Run-Typecheck.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$feRoot = Join-Path $BasePath "frontend"
$pkgPath = Join-Path $feRoot "package.json"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; ERROR="Red"; WARN="Yellow"}[$Level]
  Write-Host "[$time] [$Level] PS48: $Msg" -ForegroundColor $color
}

if (-not (Test-Path $feRoot)) { throw "FE folder not found at $feRoot" }
Set-Location $feRoot

if ($DryRun) { Write-Host "[PS48 DRY RUN] Would run typecheck in $feRoot"; exit 0 }

if (Test-Path $pkgPath) {
  $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
  if (-not $pkg.scripts) { $pkg | Add-Member -NotePropertyName "scripts" -NotePropertyValue @{} -Force }
  if (-not $pkg.scripts.typecheck) {
    $pkg.scripts | Add-Member -NotePropertyName "typecheck" -NotePropertyValue "tsc --noEmit" -Force
    $pkg | ConvertTo-Json -Depth 100 | Set-Content $pkgPath -Encoding UTF8
    Write-Log "Ensured 'typecheck' script in package.json" "SUCCESS"
  }
} else { throw "package.json not found." }

if (-not (Test-Path "node_modules")) {
  Write-Log "node_modules missing. Running npm install..." "WARN"
  npm install; if ($LASTEXITCODE -ne 0) { exit 1 }
}

Write-Log "Running tsc --noEmit..." "INFO"
npm run typecheck
if ($LASTEXITCODE -ne 0) { Write-Log "TypeScript errors found." "ERROR"; exit 1 }

Write-Log "TypeScript check passed: 0 errors" "SUCCESS"; exit 0
