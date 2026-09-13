<#
.SYNOPSIS
PS25 Script: FE-PS51-Final-Verification

.DESCRIPTION
INPUT: docker-compose.yml, src/
PROCESSING: 7 checks: health, tenant header, badge, dist exists
OUTPUT: FE51-LastRun.log + exit code
HYPERLINK:
STACK: React 18 + Vite + TypeScript + Docker
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 2
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\frontend\FE-PS51-Final-Verification.ps1
# PURPOSE: Validates PS25 FE compliance: Context, API, Badge
# FILE: FE-PS51-Final-Verification.ps1
# AUDIT: 2026-08-02

param(
    [Parameter(Mandatory=$true)]
    [string]$ComposePath,
    [string]$ApiBaseUrl = "http://localhost:8081",
    [string]$FeUrl = "http://localhost:3000",
    [string]$TestTenantId = "TENANT-PS25-TEST"
)

$ErrorCount = 0
$report = [System.Collections.ArrayList]@()
function Test-Result($name, $condition) {
    if ($condition) { $msg = "[PASS] $name"; Write-Host $msg -ForegroundColor Green }
    else { $msg = "[FAIL] $name"; Write-Host $msg -ForegroundColor Red; $script:ErrorCount++ }
    $null = $report.Add($msg)
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " FE-PS51: Final PS25 Verification - 7 Checks" -ForegroundColor Cyan

if(!(Test-Path "$ComposePath\docker-compose.yml")){ Write-Error "docker-compose.yml not found"; exit 1 }
Set-Location $ComposePath

$services = docker compose ps --format json 2>$null | ConvertFrom-Json
$unhealthy = $services | Where-Object { $_.Health -and $_.Health -ne "healthy" }
Test-Result "All services healthy" ($unhealthy.Count -eq 0)

try { $feResponse = Invoke-WebRequest -Uri $FeUrl -UseBasicParsing -TimeoutSec 10; Test-Result "FE returns 200" ($feResponse.StatusCode -eq 200) }
catch { Test-Result "FE reachable" $false }

try { $headers = @{ "X-Tenant-ID" = $TestTenantId }; $apiResponse = Invoke-WebRequest -Uri "$ApiBaseUrl/actuator/health" -Headers $headers -UseBasicParsing -TimeoutSec 10; Test-Result "BE /actuator/health 200" ($apiResponse.StatusCode -eq 200) }
catch { Test-Result "BE /actuator/health" $false }

$tenantContextFile = Get-ChildItem -Path "$ComposePath\src" -Recurse -Filter "*TenantContext*" -ErrorAction SilentlyContinue
$apiClientFile = Get-ChildItem -Path "$ComposePath\src" -Recurse -Filter "*api*" -ErrorAction SilentlyContinue
Test-Result "TenantContext.tsx exists" ($tenantContextFile.Count -gt 0)
Test-Result "API client injects X-Tenant-ID header" (Select-String -Path $apiClientFile.FullName -Pattern "X-Tenant-ID" -Quiet -ErrorAction SilentlyContinue)

Test-Result "dist/index.html exists" (Test-Path "$ComposePath\dist\index.html")
$envFile = Get-Content "$ComposePath\.env" -ErrorAction SilentlyContinue
Test-Result ".env has VITE_API_URL" ($envFile -like "*VITE_API_URL*")

# PS25 Badge
$badge = Select-String -Path "$ComposePath\src\**\*.tsx" -Pattern "PS25" -Quiet -ErrorAction SilentlyContinue
Test-Result "PS25 Compliance Badge in UI" $badge

$logPath = Join-Path $env:TEMP "FE51-LastRun.log"
Set-Content $logPath ($report -join "`n") -Encoding UTF8

if ($ErrorCount -eq 0) { Write-Host "PS25 FE VERIFICATION: PASSED" -ForegroundColor Green; exit 0 }
else { Write-Host "PS25 FE VERIFICATION: FAILED" -ForegroundColor Red; exit 1 }
