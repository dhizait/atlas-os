<#
.SYNOPSIS
PS25 Script: PS113-Add-Multi-Currency

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds currency field to vouchers. ISO 4217 support
OUTPUT: /api/vouchers supports USD, EUR, ZWL, GBP
HYPERLINK: https://www.iso.org/iso-4217-currency-codes.html
STACK: Spring Boot + JPA
COMPLIANCE: PS25 Multi-currency ledger

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 18
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS113: Adding Multi-Currency ===" -ForegroundColor Cyan

$migration = Join-Path $BasePath "backend\src\main\resources\db\migration\V9__currency.sql"
@"
ALTER TABLE vouchers ADD COLUMN currency VARCHAR(3) DEFAULT 'USD';
ALTER TABLE usage_events ADD COLUMN currency VARCHAR(3) DEFAULT 'USD';
"@ | Out-File $migration -Encoding utf8

Write-Host "PS113 Done: Vouchers now have currency field" -ForegroundColor Green
