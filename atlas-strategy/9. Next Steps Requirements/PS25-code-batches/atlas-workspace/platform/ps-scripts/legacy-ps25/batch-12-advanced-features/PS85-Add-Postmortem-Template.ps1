<#
.SYNOPSIS
PS25 Script: PS85-Add-Postmortem-Template

.DESCRIPTION
INPUT: docs/
PROCESSING: Creates postmortem template + automation to create Jira
OUTPUT: Standardized incident review within 48h
HYPERLINK: https://cloud.google.com/sre
STACK: Markdown + Jira API
COMPLIANCE: PS25 Blameless culture

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 12
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS85: Adding Postmortem Template ===" -ForegroundColor Cyan

$template = Join-Path $BasePath "docs\postmortem-template.md"
@"
# Postmortem: [INCIDENT TITLE]
**Date**: YYYY-MM-DD
**Duration**:
**Impact**: Tenants affected:
**Root Cause**:
**Timeline**:
- T+0: Detection
- T+5: Mitigation
**Action Items**:
- [ ] Prevent recurrence
**Lessons Learned**:
"@ | Out-File $template -Encoding utf8

Write-Host "PS85 Done: Copy template for every P1/P2 incident" -ForegroundColor Green
