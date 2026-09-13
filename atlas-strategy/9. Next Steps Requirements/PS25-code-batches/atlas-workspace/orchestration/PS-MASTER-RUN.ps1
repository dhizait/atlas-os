<#
.SYNOPSIS
PS-MASTER-RUN.ps1 - PS25 Multi-Tenancy Automation v3.4 - 125 Scripts
Generated: 08/06/2026
USAGE:.\PS-MASTER-RUN.ps1 -BasePath "C:\Atlas\releases\R01\demo-bank" [-Full -Force -WhatIf]
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BasePath,
    [switch]$Full,
    [switch]$Force,
    [switch]$WhatIf,
    [switch]$ValidateOnly,
    [switch]$CleanInstall,
    [switch]$SkipFE,
    [switch]$SkipTests,
    [string]$DefaultTenantId = "TENANT001"
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$WorkspaceRoot = Join-Path $BasePath "atlas-workspace"
$PsScriptsRoot = Join-Path $WorkspaceRoot "platform\ps-scripts"
$BeRoot = Join-Path $BasePath "backend"
$FeRoot = Join-Path $BasePath "frontend"
$MobileRoot = Join-Path $BasePath "mobile"
$RepoRoot = $BasePath
$BackupRoot = Join-Path $BasePath "demo-bank-backups"
$LogsRoot = Join-Path $scriptDir "logs"
if (!(Test-Path $LogsRoot)) { New-Item $LogsRoot -ItemType Directory -Force | Out-Null }
$LogFile = "$LogsRoot\PS25-Run-Log_$Timestamp.txt"

$Ps98 = Join-Path $scriptDir "PS98-BackupRestore.ps1"
$Ps99 = Join-Path $scriptDir "PS99-Validate-And-Cleanup.ps1"
$Ps100 = Join-Path $scriptDir "PS100-Report-Generator.ps1"
$Ps102 = Join-Path $scriptDir "PS102-Create-Audit-Batches.ps1"
$RollbackNeeded = $false

function Write-Log {
    param([string]$Msg, [string]$Level="INFO")
    $line = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Msg"
    $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"; WHATIF="Magenta"}[$Level]
    Write-Host $line -ForegroundColor $color
    $line | Out-File $LogFile -Append
}

function Invoke-PS98 {
    param([string]$Action, [string]$ProjectPath, [string]$ProjectName)
    if (!(Test-Path $Ps98)) { throw "PS98 not found at $Ps98" }
    Write-Log "$Action $ProjectName"
    if($WhatIf){
        Write-Log "[WHATIF] Would run PS98 $Action" "WHATIF"
    } else {
        & $Ps98 -Action $Action -ProjectPath $ProjectPath -ProjectName $ProjectName -RepoRoot $RepoRoot
        if($LASTEXITCODE -ne 0){ throw "PS98 $Action failed with code $LASTEXITCODE" }
    }
}

function Invoke-Batch {
    param([int]$BatchNum)
    $batchDir = Get-ChildItem $PsScriptsRoot -Directory | Where-Object {$_.Name -like "batch-$("{0:D2}" -f $BatchNum)-*"}
    if(!$batchDir){ Write-Log "Batch $BatchNum folder not found, skipping" "WARN"; return }
    $scripts = Get-ChildItem $batchDir.FullName -Filter "PS*.ps1" | Sort-Object Name
    Write-Log "=== BATCH $BatchNum : $($batchDir.Name) : $($scripts.Count) scripts ==="
    foreach($s in $scripts){
        Write-Log "Running $($s.Name)"
        if($WhatIf){ Write-Log "[WHATIF] Would run $($s.FullName)" "WHATIF"; continue }
        & $s.FullName -BasePath $BasePath -Force:$Force -WhatIf:$WhatIf
        if($LASTEXITCODE -ne 0){ throw "$($s.Name) failed with exit code $LASTEXITCODE" }
    }
}

try {
    Write-Log "PS25 Master Run Starting v3.4 BasePath=$BasePath Full=$Full"

    if($CleanInstall){
        Write-Log "CLEAN INSTALL MODE" "WARN"
        if(Test-Path $FeRoot){ Remove-Item "$FeRoot\node_modules" -Recurse -Force -ErrorAction SilentlyContinue }
        exit 0
    }

    if ($ValidateOnly) {
        Write-Log "Running validation only..."
        & $Ps99 -BasePath $BasePath
        exit 0
    }

    if($Full){
        Write-Log "FULL MODE: Running backups" "WARN"
        Invoke-PS98 -Action "Backup" -ProjectPath $FeRoot -ProjectName "demo-bank-fe"
        Invoke-PS98 -Action "Backup" -ProjectPath $BeRoot -ProjectName "demo-bank-be"
        if(Test-Path $MobileRoot){ Invoke-PS98 -Action "Backup" -ProjectPath $MobileRoot -ProjectName "demo-bank-mobile" }
        $RollbackNeeded = $true
    }

    for($i=1; $i -le 20; $i++){
        # Explicit handling notes
        switch($i){
            2 { Write-Log "Batch 02: Security + Search - Includes PS33-Add-Apache-Solr" "INFO" }
            17 { if($SkipFE){ Write-Log "Skipping Batch 17 Mobile + SDKs" "WARN"; continue } }
        }
        Invoke-Batch -BatchNum $i
    }

    # Final validation + report + audit
    Write-Log "Running Final Validation: PS99" "INFO"
    & $Ps99 -BasePath $BasePath

    Write-Log "Running Report Generation: PS100" "INFO"
    & $Ps100 -BasePath $BasePath

    Write-Log "Running Audit Batch Creation: PS102" "INFO"
    & $Ps102 -BasePath $BasePath

    $RollbackNeeded = $false
    Write-Log "PS25 Summary: All 20 batches completed successfully" "SUCCESS"
    Write-Host "`nPS25 DONE. Log: $LogFile" -ForegroundColor Green
}
catch {
    Write-Log "FATAL ERROR: $($_.Exception.Message)" "ERROR"
    if($RollbackNeeded -and $Full){
        Write-Log "ROLLBACK INITIATED" "WARN"
        Invoke-PS98 -Action "Restore" -ProjectPath $FeRoot -ProjectName "demo-bank-fe"
        Invoke-PS98 -Action "Restore" -ProjectPath $BeRoot -ProjectName "demo-bank-be"
        Write-Log "ROLLBACK COMPLETE" "SUCCESS"
    }
    throw
}