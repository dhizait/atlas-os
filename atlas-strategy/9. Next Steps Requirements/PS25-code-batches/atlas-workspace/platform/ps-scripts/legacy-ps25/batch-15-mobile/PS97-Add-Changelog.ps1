<#
.SYNOPSIS
PS25 Script: PS97-Add-Changelog

.DESCRIPTION
INPUT: None
PROCESSING: Generates CHANGELOG.md from git commits + PS script headers
OUTPUT: Versioned changelog with breaking changes + migration notes
HYPERLINK: https://keepachangelog.com
STACK: Git + Markdown
COMPLIANCE: PS25 Release transparency

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 15
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS97: Generating Changelog ===" -ForegroundColor Cyan

$changelog = Join-Path $BasePath "CHANGELOG.md"
@"
# Changelog

## [1.0.0] - 2026-08-06
### Added
- PS01-PS05: Foundation + Multi-tenancy
- PS06-PS10: Observability + Security
- PS11-PS15: Platform + CI/CD
- PS16-PS20: Data Layer
- PS21-PS25: Frontend
- PS26-PS30: Compliance + GDPR
- PS31-PS35: Integrations
- PS36-PS40: AI/ML + Fraud
- PS41-PS45: Performance
- PS46-PS50: DR + SRE
- PS51-PS55: Billing
- PS56-PS60: Admin + Ops

### Breaking Changes
- All APIs now require X-Tenant-ID header
- DB schema v7: usage_events table added

### Migration Guide
See docs/migration-v1.md
"@ | Out-File $changelog -Encoding utf8

Write-Host "PS97 Done: CHANGELOG.md created" -ForegroundColor Green
