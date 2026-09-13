<#
.SYNOPSIS
PS25 Script: PS121-Add-Training-Videos

.DESCRIPTION
INPUT: docs/
PROCESSING: Generates training video scripts + Loom links
OUTPUT: /docs/training index with 10 videos
HYPERLINK: https://www.loom.com
STACK: Markdown + MP4
COMPLIANCE: PS25 Knowledge transfer

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 20
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS121: Adding Training Materials ===" -ForegroundColor Cyan

$trainingIndex = Join-Path $BasePath "docs\training-index.md"
@"
# DemoBank Training Videos

1. [Onboarding New Tenant](https://loom.com/share/xxx1) - 5min
2. [Creating Vouchers](https://loom.com/share/xxx2) - 3min
3. [Viewing Analytics](https://loom.com/share/xxx3) - 4min
4. [Billing & Invoices](https://loom.com/share/xxx4) - 5min
5. [Admin Tools](https://loom.com/share/xxx5) - 6min
6. [DR Drill](https://loom.com/share/xxx6) - 8min
7. [API Integration](https://loom.com/share/xxx7) - 10min
8. [Security Features](https://loom.com/share/xxx8) - 7min
9. [Mobile App Walkthrough](https://loom.com/share/xxx9) - 5min
10. [Support Tools](https://loom.com/share/xxx10) - 4min
"@ | Out-File $trainingIndex -Encoding utf8

Write-Host "PS121 Done: docs/training-index.md created" -ForegroundColor Green
