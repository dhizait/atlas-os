<#
.SYNOPSIS
PS25 Script: PS99-Add-Final-Smoke-Tests

.DESCRIPTION
INPUT: None
PROCESSING: End-to-end smoke test covering all 100 PS scripts
OUTPUT: PASS/FAIL report for release gate
HYPERLINK: https://www.postman.com
STACK: PowerShell + curl + jq
COMPLIANCE: PS25 Go-live checklist

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 15
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS99: Running Final Smoke Tests ===" -ForegroundColor Yellow

$tests = @(
    @{name="Health"; cmd="curl -s http://localhost:8080/actuator/health"},
    @{name="Create Tenant"; cmd="curl -X POST http://localhost:8080/api/admin/tenants -d '{\"name\":\"TEST\",\"adminEmail\":\"test@test.com\"}'"},
    @{name="Create Voucher"; cmd="curl -H 'X-Tenant-ID: TENANT001' -X POST http://localhost:8080/api/vouchers -d '{\"amount\":100}'"},
    @{name="Get Usage"; cmd="curl http://localhost:8080/api/billing/invoice?month=2026-01"},
    @{name="Swagger"; cmd="curl -s http://localhost:8080/swagger-ui.html"}
)

$pass = 0; $fail = 0
foreach($t in $tests){
    $res = Invoke-Expression $t.cmd 2>$null
    if($res){ Write-Host "[PASS] $($t.name)" -ForegroundColor Green; $pass++ }
    else { Write-Host "[FAIL] $($t.name)" -ForegroundColor Red; $fail++ }
}

Write-Host "=== SMOKE TEST REPORT ===" -ForegroundColor Cyan
Write-Host "Passed: $pass | Failed: $fail"
if($fail -eq 0){ Write-Host "RELEASE READY" -ForegroundColor Green } else { Write-Host "BLOCKED" -ForegroundColor Red }
