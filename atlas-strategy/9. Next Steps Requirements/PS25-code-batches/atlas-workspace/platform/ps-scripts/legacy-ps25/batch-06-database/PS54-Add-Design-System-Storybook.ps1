<#
.SYNOPSIS
PS25 Script: PS54-Add-Design-System-Storybook

.DESCRIPTION
INPUT: frontend/
PROCESSING: Adds Storybook + Tenant theming via CSS variables
OUTPUT: Component library with per-tenant brand colors
HYPERLINK: https://storybook.js.org
STACK: Storybook 7 + Tailwind + CSS Variables
COMPLIANCE: PS25 Consistent UI across 100 tenants

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS54: Adding Design System + Storybook ===" -ForegroundColor Cyan

$sb = "npx storybook@latest init"
Invoke-Expression "cd $(Join-Path $BasePath 'frontend') && $sb"

$theme = Join-Path $BasePath "frontend\src\theme\tenantTheme.css"
@"
:root { --primary: #0066cc; --secondary: #004499; }
[data-tenant="TENANT001"] { --primary: #cc0000; --secondary: #990000; }
[data-tenant="TENANT002"] { --primary: #00cc66; --secondary: #009944; }
.button { background: var(--primary); }
"@ | Out-File $theme -Encoding utf8

Write-Host "PS54 Done: Run 'npm run storybook'. Theme via data-tenant attribute" -ForegroundColor Green
