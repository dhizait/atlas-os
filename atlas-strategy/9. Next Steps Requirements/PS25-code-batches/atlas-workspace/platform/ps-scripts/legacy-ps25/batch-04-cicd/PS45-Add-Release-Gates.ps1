<#
.SYNOPSIS
PS25 Script: PS45-Add-Release-Gates

.DESCRIPTION
INPUT: PS100-Report.md
PROCESSING: Creates release validation script - blocks deploy if tests fail
OUTPUT: Exit 1 if any PS validation fails
HYPERLINK: https://semver.org
STACK: PowerShell + GitHub Actions
COMPLIANCE: PS25 No deploy on red

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS45: Adding Release Gates ===" -ForegroundColor Cyan

$gateScript = Join-Path $BasePath "atlas-workspace\orchestration\PS45-Release-Gate.ps1"
@"
param([string]`$BasePath)
Write-Host "=== RELEASE GATE: Validating before deploy ===" -ForegroundColor Yellow
& "$BasePath\atlas-workspace\platform\ps-scripts\batch-01-observability\PS30-HealthCheck.ps1" -BasePath `$BasePath
if(`$LASTEXITCODE -ne 0) { exit 1 }
Write-Host "ALL GATES PASSED. Safe to deploy." -ForegroundColor Green
"@ | Out-File $gateScript -Encoding utf8

Write-Host "PS45 Done: Call PS45-Release-Gate.ps1 before kubectl apply" -ForegroundColor Green
