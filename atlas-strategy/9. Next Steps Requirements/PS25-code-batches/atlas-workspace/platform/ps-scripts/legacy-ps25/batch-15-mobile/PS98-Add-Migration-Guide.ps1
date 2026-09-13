<#
.SYNOPSIS
PS25 Script: PS98-Add-Migration-Guide

.DESCRIPTION
INPUT: docs/
PROCESSING: Creates step-by-step migration guide for existing banks
OUTPUT: docs/migration-v1.md with rollback plan
HYPERLINK: https://www.postgresql.org/docs/current/upgrading.html
STACK: Markdown
COMPLIANCE: PS25 Zero-downtime migration

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 15
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS98: Adding Migration Guide ===" -ForegroundColor Cyan

$docsDir = Join-Path $BasePath "docs"
New-Item -ItemType Directory -Force $docsDir | Out-Null

$migration = Join-Path $docsDir "migration-v1.md"
@"
# Migration Guide v1.0

## Pre-requisites
1. Backup DB: `pg_dump demobank > backup.sql`
2. Set maintenance window: 2 hours

## Steps
1. Run PS01-PS05 for foundation
2. Run DB migrations V1-V7
3. Deploy backend with feature flags off
4. Enable multi-tenancy: set X-Tenant-ID
5. Run smoke tests PS99

## Rollback
1. Restore DB from backup.sql
2. Revert to previous docker image
"@ | Out-File $migration -Encoding utf8

Write-Host "PS98 Done: docs/migration-v1.md created" -ForegroundColor Green
