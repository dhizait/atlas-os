<#
.SYNOPSIS
PS99-Validate-And-Cleanup-125.ps1 - PS25 Validation & Health Check v3.0
Generated: 08/06/2026
USAGE:.\PS99-Validate-And-Cleanup-125.ps1 -BasePath C:\Atlas\releases\R01\demo-bank [-AutoFix]
#>

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$AutoFix,
  [switch]$Offline
)

$ErrorActionPreference = "Continue"
$BeRoot = Join-Path $BasePath "backend"
$FeRoot = Join-Path $BasePath "frontend\demo-bank-fe"
$MobileRoot = Join-Path $BasePath "mobile"
$Results = @()
$FailCount = 0

function Test-Result {
  param([string]$Name, [bool]$Passed, [string]$Detail)
  $status = if($Passed){"PASS"}else{"FAIL"}
  $color = if($Passed){"Green"}else{"Red"}
  Write-Host "[$status] $Name : $Detail" -ForegroundColor $color
  $script:Results += [PSCustomObject]@{Test=$Name;Status=$status;Detail=$Detail}
  if(-not $Passed){$script:FailCount++}
}

Write-Host "================================================" -ForegroundColor Magenta
Write-Host " PS99: PS25 Validation Starting v3.0" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta

# TEST 1: Backend Health
try{
  $health = Invoke-RestMethod "http://localhost:8081/actuator/health" -TimeoutSec 5 -ErrorAction Stop
  Test-Result "Backend Health" ($health.status -eq "UP") "Spring Boot UP"
}catch{
  Test-Result "Backend Health" $false "Cannot reach http://localhost:8081/actuator/health"
}

# TEST 2: Tenant Enforcement - Must reject without header
try{
  $resp = Invoke-WebRequest "http://localhost:8081/api/vouchers" -TimeoutSec 5 -ErrorAction SilentlyContinue
  Test-Result "Tenant Enforcement" $false "API allowed request without X-Tenant-ID. Got $($resp.StatusCode)"
}catch{
  if($_.Exception.Response.StatusCode.value__ -eq 400){
    Test-Result "Tenant Enforcement" $true "Correctly returned 400 for missing header"
  }else{
    Test-Result "Tenant Enforcement" $false "Wrong error: $($_.Exception.Message)"
  }
}

# TEST 3: Tenant Isolation
try{
  $t1 = Invoke-RestMethod "http://localhost:8081/api/vouchers" -Headers @{"X-Tenant-ID"="TENANT001"} -TimeoutSec 5
  $t2 = Invoke-RestMethod "http://localhost:8081/api/vouchers" -Headers @{"X-Tenant-ID"="TENANT002"} -TimeoutSec 5
  $isolated = ($t1 | ConvertTo-Json) -ne ($t2 | ConvertTo-Json)
  Test-Result "Tenant Isolation" $isolated "TENANT001 vs TENANT002 data differs"
}catch{
  Test-Result "Tenant Isolation" $false "Error calling API with headers"
}

# TEST 4: ClickHouse Health
try{
  $ch = Invoke-RestMethod "http://localhost:8123/ping" -TimeoutSec 3
  Test-Result "ClickHouse DW" ($ch -eq "Ok") "ClickHouse responding"
}catch{
  Test-Result "ClickHouse DW" $false "ClickHouse not reachable"
}

# TEST 5: Metabase Health
try{
  $mb = Invoke-RestMethod "http://localhost:3001/api/health" -TimeoutSec 3
  Test-Result "Metabase BI" ($mb.status -eq "ok") "Metabase OK"
}catch{
  Test-Result "Metabase BI" $false "Metabase not reachable"
}

# TEST 6: Frontend Build
Test-Result "Frontend Dist" (Test-Path "$FeRoot\dist\index.html") "dist/index.html exists"

# TEST 7: Mobile Build
Test-Result "Mobile App" (Test-Path "$MobileRoot\app\index.tsx") "React Native app exists"

# TEST 8: Rate Limit
try{
  1..1001 | ForEach-Object { Invoke-WebRequest "http://localhost:8081/api/vouchers" -Headers @{"X-Tenant-ID"="TENANT001"} -ErrorAction SilentlyContinue | Out-Null }
  Test-Result "Rate Limiting" $false "Did not hit 429"
}catch{
  if($_.Exception.Response.StatusCode.value__ -eq 429){
    Test-Result "Rate Limiting" $true "429 returned after 1000 req"
  }else{
    Test-Result "Rate Limiting" $false "Unexpected error"
  }
}

# TEST 9: Flyway Migration
Push-Location $BeRoot
try{
  mvn flyway:info -q
  Test-Result "Flyway Migration" ($LASTEXITCODE -eq 0) "DB at latest migration"
}catch{
  Test-Result "Flyway Migration" $false "Flyway check failed"
}
Pop-Location

Write-Host "================================================" -ForegroundColor Magenta
Write-Host " SUMMARY: $($Results.Count - $FailCount)/$($Results.Count) PASSED" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta

if($FailCount -eq 0){
  Write-Host "PS25 VALIDATION: PASSED. Ready for sign-off" -ForegroundColor Green
  exit 0
}else{
  Write-Host "PS25 VALIDATION: FAILED. $FailCount tests failed" -ForegroundColor Red
  if($AutoFix){
    Write-Host "Running PS-MASTER-RUN-125.ps1 -Force to fix..." -ForegroundColor Yellow
    & "$PSScriptRoot\PS-MASTER-RUN-125.ps1" -BasePath $BasePath -Force
  }
  exit 1
}