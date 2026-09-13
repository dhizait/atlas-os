<#
.SYNOPSIS
PS25 Script: PS124-Add-Warranty-Support

.DESCRIPTION
INPUT: docs/
PROCESSING: Creates 90-day warranty + support contact sheet
OUTPUT: /docs/warranty.md with escalation matrix
HYPERLINK: https://example.com
STACK: Markdown
COMPLIANCE: PS25 Post-go-live support

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 20
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS124: Adding Warranty Support ===" -ForegroundColor Cyan

$warranty = Join-Path $BasePath "docs\warranty.md"
@"
# 90-Day Warranty & Support

**Warranty Period**: 2026-08-06 to 2026-11-04

## What's Covered
- Bug fixes
- Security patches
- Performance tuning

## Escalation
| Level | Contact | Response |
| --- | --- | --- |
| L1 Support | support@demo-bank.com | 2 hours |
| L2 Engineering | eng@demo-bank.com | 1 hour |
| L3 On-call | +263-xxx-xxx | 15 min |

## Exclusions
- New features
- Third-party outages
"@ | Out-File $warranty -Encoding utf8

Write-Host "PS124 Done: docs/warranty.md created" -ForegroundColor Green
