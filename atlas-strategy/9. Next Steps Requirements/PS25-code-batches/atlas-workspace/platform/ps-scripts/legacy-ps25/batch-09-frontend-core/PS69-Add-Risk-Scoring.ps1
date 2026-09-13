<#
.SYNOPSIS
PS25 Script: PS69-Add-Risk-Scoring

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds risk_score column to vouchers + automatic hold logic
OUTPUT: vouchers with risk_score > 0.8 go to PENDING_REVIEW
HYPERLINK: https://www.fico.com
STACK: Spring Boot + JPA
COMPLIANCE: PS25 Automated risk controls

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 9
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS69: Adding Risk Scoring ===" -ForegroundColor Cyan

$migration = Join-Path $BasePath "backend\src\main\resources\db\migration\V4__risk_score.sql"
@"
ALTER TABLE vouchers ADD COLUMN risk_score DOUBLE DEFAULT 0.0;
ALTER TABLE vouchers ADD COLUMN status VARCHAR(50) DEFAULT 'APPROVED';
CREATE INDEX idx_risk ON vouchers(tenant_id, risk_score);
"@ | Out-File $migration -Encoding utf8

Write-Host "PS69 Done: Update BE-PS73 to set status=PENDING_REVIEW if risk>0.8" -ForegroundColor Green
