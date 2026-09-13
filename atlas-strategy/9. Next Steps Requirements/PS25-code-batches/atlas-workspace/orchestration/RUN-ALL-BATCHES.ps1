<#
.SYNOPSIS
RUN-ALL-BATCHES.ps1 - PS25 Batch Execution v4.1
.DESCRIPTION
Runs PS25 batches 1-20 from platform\ps-scripts. Supports -Batch to run slices and -DryRun to preview.
USAGE:
.\RUN-ALL-BATCHES.ps1 -BasePath "C:\Atlas\releases\R01\demo-bank" -Batch 18 -DryRun
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BasePath,
    [ValidateSet("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","All")]
    [string]$Batch = "All",
    [switch]$SkipBackup,
    [switch]$SkipTests,
    [switch]$SkipFE,
    [switch]$DryRun,
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$WorkspaceRoot = Join-Path $BasePath "atlas-workspace"
$PsScriptsRoot = Join-Path $WorkspaceRoot "platform\ps-scripts"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = Join-Path $ScriptDir "logs\BATCH-RUN-$Timestamp.log"
$IsDryRun = $DryRun -or $WhatIf
if (!(Test-Path (Join-Path $ScriptDir "logs"))) { New-Item (Join-Path $ScriptDir "logs") -ItemType Directory -Force | Out-Null }

function Write-BatchLog {
    param([string]$Msg, [string]$Level="INFO")
    $line = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Msg"
    $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"; DRYRUN="Magenta"}[$Level]
    Write-Host $line -ForegroundColor $color
    $line | Out-File $LogFile -Append
}

function Invoke-BatchFolder {
    param([int]$Num)
    $batchDir = Get-ChildItem $PsScriptsRoot -Directory | Where-Object {$_.Name -like "batch-$("{0:D2}" -f $Num)-*"}
    if(!$batchDir){ Write-BatchLog "Batch $Num not found" "WARN"; return }
    Write-BatchLog "--- BATCH $Num ---"
    $scripts = Get-ChildItem $batchDir.FullName -Filter "PS*.ps1" | Sort-Object Name
    foreach($s in $scripts){
        if($IsDryRun){ Write-BatchLog "[DRYRUN] Would run $($s.Name)" "DRYRUN"; continue }
        & $s.FullName -BasePath $BasePath
        if($LASTEXITCODE -ne 0){ throw "$($s.Name) failed" }
    }
}

try {
    if ($IsDryRun) { Write-BatchLog "DRY RUN MODE" "DRYRUN" }
    Write-BatchLog "PS25 BATCH RUN STARTING v4.1 | BasePath: $BasePath"

    if ($Batch -eq "All") {
        1..20 | ForEach-Object {
            if($_ -eq 17 -and $SkipFE){ Write-BatchLog "Skipping Batch $_ Mobile" "WARN"; return }
            Invoke-BatchFolder -Num $_
        }
    } else {
        Invoke-BatchFolder -Num ([int]$Batch)
    }

    Write-BatchLog "RUN COMPLETE. Check log: $LogFile" "SUCCESS"
}
catch {
    Write-BatchLog "FATAL ERROR: $($_.Exception.Message)" "ERROR"
    exit 1
}