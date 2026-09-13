<#
.SYNOPSIS
PS-ATLAS-MASTER-RUN.ps1 - ATLAS R17 Automation v1.0 - 125 Scripts
Generated: 18/08/2026
USAGE:.\PS-ATLAS-MASTER-RUN.ps1 -BasePath "C:\Atlas\releases\R01\demo-bank" [-Full -Force -WhatIf]
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BasePath,
    [switch]$Full,
    [switch]$Force,
    [switch]$WhatIf,
    [switch]$ValidateOnly,
    [switch]$CleanInstall,
    [switch]$SkipBuild,
    [string]$DefaultTenantId = "TENANT001"
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$WorkspaceRoot = Join-Path $BasePath "_work-desk\atlas-workspace"
$PsScriptsRoot = Join-Path $WorkspaceRoot "platform\ps-scripts\atlas"
$RepoRoot = $BasePath
$BackupRoot = Join-Path $BasePath "demo-bank-backups"
$LogsRoot = Join-Path $scriptDir "logs"
if (!(Test-Path $LogsRoot)) { New-Item $LogsRoot -ItemType Directory -Force | Out-Null }
$LogFile = "$LogsRoot\PS-ATLAS-RUN-$Timestamp.txt"

$Ps98 = Join-Path $scriptDir "PS98-ATLAS-BackupRestore.ps1"
$Ps99 = Join-Path $scriptDir "PS99-ATLAS-Validate-And-Cleanup.ps1"
$Ps100 = Join-Path $scriptDir "PS100-ATLAS-Report-Generator.ps1"
$Ps102 = Join-Path $scriptDir "PS102-ATLAS-Create-Audit-Batches.ps1"
$PsBuild = Join-Path $PsScriptsRoot "build\Build-All-Atlas-PSNs.ps1"
$RollbackNeeded = $false

#region HELPER FUNCTIONS
function Write-Log {
    param(
        [string]$Msg,
        [string]$Level = "INFO"
    )
    $line = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Msg"
    $color = @{
        INFO = "Cyan"
        SUCCESS = "Green"
        WARN = "Yellow"
        ERROR = "Red"
        WHATIF = "Magenta"
    }[$Level]
    Write-Host $line -ForegroundColor $color
    $line | Out-File $LogFile -Append
}

function Invoke-PS98 {
    param(
        [string]$Action,
        [string]$ProjectPath,
        [string]$ProjectName
    )
    if (!(Test-Path $Ps98)) { throw "PS98-ATLAS not found at $Ps98" }
    Write-Log "$Action $ProjectName"
    if ($WhatIf) {
        Write-Log "[WHATIF] Would run PS98-ATLAS $Action" "WHATIF"
    }
    else {
        & $Ps98 -Action $Action -ProjectPath $ProjectPath -ProjectName $ProjectName -RepoRoot $RepoRoot
        if ($LASTEXITCODE -ne 0) { throw "PS98-ATLAS $Action failed with code $LASTEXITCODE" }
    }
}

function Invoke-Batch {
    param([int]$BatchNum)
    $batchDir = Get-ChildItem $PsScriptsRoot -Directory | Where-Object { $_.Name -like "batch-$("{0:D2}" -f $BatchNum)-*" }
    if (!$batchDir) {
        Write-Log "Batch $BatchNum folder not found, skipping" "WARN"
        return
    }
    $scripts = Get-ChildItem $batchDir.FullName -Filter "PS*.ps1" | Sort-Object Name
    Write-Log "=== BATCH $BatchNum : $($batchDir.Name) : $($scripts.Count) scripts ==="
    foreach ($s in $scripts) {
        Write-Log "Running $($s.Name)"
        if ($WhatIf) {
            Write-Log "[WHATIF] Would run $($s.FullName)" "WHATIF"
            continue
        }
        & $s.FullName -BasePath $BasePath -Force:$Force -WhatIf:$WhatIf
        if ($LASTEXITCODE -ne 0) { throw "$($s.Name) failed with exit code $LASTEXITCODE" }
    }
}
#endregion

#region MAIN EXECUTION
try {
    Write-Log "PS-ATLAS-MASTER-RUN Starting v1.0 BasePath=$BasePath Full=$Full"

    if ($CleanInstall) {
        Write-Log "CLEAN INSTALL MODE" "WARN"
        exit 0
    }

    if ($ValidateOnly) {
        Write-Log "Running validation only..."
        & $Ps99 -BasePath $BasePath
        exit 0
    }

    if ($Full -and -not $SkipBuild) {
        Write-Log "FULL MODE: Running Build from SSOT" "WARN"
        & $PsBuild -BasePath $BasePath

        Write-Log "FULL MODE: Running backups" "WARN"
        Invoke-PS98 -Action "Backup" -ProjectPath $BasePath -ProjectName "demo-bank-atlas"
        $RollbackNeeded = $true
    }

    for ($i = 1; $i -le 20; $i++) {
        switch ($i) {
            2 { Write-Log "Batch 02: Security + EventBus + Search" "INFO" }
            17 { Write-Log "Batch 17: CV2 Services + Adapters" "INFO" }
        }
        Invoke-Batch -BatchNum $i
    }

    Write-Log "Running Final Validation: PS99-ATLAS" "INFO"
    & $Ps99 -BasePath $BasePath

    Write-Log "Running Report Generation: PS100-ATLAS" "INFO"
    & $Ps100 -BasePath $BasePath

    Write-Log "Running Audit Batch Creation: PS102-ATLAS" "INFO"
    & $Ps102 -BasePath $BasePath

    $RollbackNeeded = $false
    Write-Log "PS-ATLAS-MASTER-RUN Summary: All 20 batches completed successfully" "SUCCESS"
    Write-Host "`nPS-ATLAS-MASTER-RUN DONE. Log: $LogFile" -ForegroundColor Green
}
catch {
    Write-Log "FATAL ERROR: $($_.Exception.Message)" "ERROR"
    if ($RollbackNeeded -and $Full) {
        Write-Log "ROLLBACK INITIATED" "WARN"
        Invoke-PS98 -Action "Restore" -ProjectPath $BasePath -ProjectName "demo-bank-atlas"
        Write-Log "ROLLBACK COMPLETE" "SUCCESS"
    }
    throw
}
#endregion