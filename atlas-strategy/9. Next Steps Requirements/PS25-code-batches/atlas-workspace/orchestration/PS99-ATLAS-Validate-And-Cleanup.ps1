<#
.SYNOPSIS
PS99-ATLAS-Validate-And-Cleanup.ps1 - ATLAS Validation & Health Check v1.0
Generated: 18/08/2026
USAGE:.\PS99-ATLAS-Validate-And-Cleanup.ps1 -BasePath C:\Atlas\releases\R01\demo-bank [-AutoFix]
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BasePath,
    [switch]$AutoFix
)

$ErrorActionPreference = "Continue"
$WorkspaceRoot = Join-Path $BasePath "_work-desk\atlas-workspace"
$Results = @()
$FailCount = 0
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = Join-Path $WorkspaceRoot "_logs\PS99-ATLAS-Validation-$Timestamp.log"
if (!(Test-Path (Split-Path $LogFile))) { New-Item (Split-Path $LogFile) -ItemType Directory -Force | Out-Null }

#region HELPER FUNCTIONS
function Write-ValidationLog {
    param([string]$Msg, [string]$Level="INFO")
    $line = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Msg"
    $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"; FAIL="Red"; PASS="Green"}[$Level]
    Write-Host $line -ForegroundColor $color
    $line | Out-File $LogFile -Append
}

function Test-Result {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Detail
    )
    $status = if($Passed){"PASS"}else{"FAIL"}
    Write-ValidationLog "[$status] $Name : $Detail" $status
    $script:Results += [PSCustomObject]@{Test=$Name;Status=$status;Detail=$Detail}
    if(-not $Passed){$script:FailCount++}
#endregion

#region MAIN VALIDATION
Write-ValidationLog "================================================" "INFO"
Write-ValidationLog " PS99-ATLAS: Validation Starting v1.0" "INFO"
Write-ValidationLog "================================================" "INFO"

# TEST 1: EventBus Kafka Health
try {
    $eb = Invoke-RestMethod "http://localhost:9092/health" -TimeoutSec 5 -ErrorAction Stop
    Test-Result "EventBus Kafka" $true "Kafka responding on 9092"
}
catch {
    Test-Result "EventBus Kafka" $false "Cannot reach http://localhost:9092/health"
}

# TEST 2: Postgres DB Health
try {
    $db = Invoke-RestMethod "http://localhost:5432/health" -TimeoutSec 5 -ErrorAction Stop
    Test-Result "Postgres DB" $true "Postgres responding on 5432"
}
catch {
    Test-Result "Postgres DB" $false "Cannot reach http://localhost:5432/health"
}

# TEST 3: Core Service Health
try {
    $svc = Invoke-RestMethod "http://localhost:8080/actuator/health" -TimeoutSec 5 -ErrorAction Stop
    Test-Result "Core Service" ($svc.status -eq "UP") "Spring Boot UP"
}
catch {
    Test-Result "Core Service" $false "Cannot reach http://localhost:8080/actuator/health"
}

# TEST 4: ClickHouse DW Health
try {
    $ch = Invoke-RestMethod "http://localhost:8123/ping" -TimeoutSec 3 -ErrorAction Stop
    Test-Result "ClickHouse DW" ($ch -eq "Ok") "ClickHouse responding"
}
catch {
    Test-Result "ClickHouse DW" $false "ClickHouse not reachable on 8123"
}

# TEST 5: Tenant Isolation
try {
    $t1 = Invoke-RestMethod "http://localhost:8080/api/data" -Headers @{"X-Tenant-ID"="TENANT001"} -TimeoutSec 5
    $t2 = Invoke-RestMethod "http://localhost:8080/api/data" -Headers @{"X-Tenant-ID"="TENANT002"} -TimeoutSec 5
    $isolated = ($t1 | ConvertTo-Json) -ne ($t2 | ConvertTo-Json)
    Test-Result "Tenant Isolation" $isolated "TENANT001 vs TENANT002 data differs"
}
catch {
    Test-Result "Tenant Isolation" $false "Error calling API with tenant headers"
}

# TEST 6: Docker Services
try {
    $docker = docker ps --format "{{.Names}}" 2>$null
    $hasCore = $docker -match "atlas-core"
    Test-Result "Docker Services" $hasCore "atlas-core container running"
}
catch {
    Test-Result "Docker Services" $false "Docker not accessible"
}
#endregion

#region SUMMARY AND EXIT
Write-ValidationLog "================================================" "INFO"
Write-ValidationLog " SUMMARY: $($Results.Count - $FailCount)/$($Results.Count) PASSED" "INFO"
Write-ValidationLog "================================================" "INFO"

if($FailCount -eq 0) {
    Write-ValidationLog "PS99-ATLAS VALIDATION: PASSED. Ready for sign-off" "SUCCESS"
    exit 0
}
else {
    Write-ValidationLog "PS99-ATLAS VALIDATION: FAILED. $FailCount tests failed" "ERROR"
    if($AutoFix) {
        Write-ValidationLog "Running PS-ATLAS-MASTER-RUN.ps1 -Force to fix..." "WARN"
        & "$PSScriptRoot\PS-ATLAS-MASTER-RUN.ps1" -BasePath $BasePath -Force
    }
    exit 1
}
#endregion