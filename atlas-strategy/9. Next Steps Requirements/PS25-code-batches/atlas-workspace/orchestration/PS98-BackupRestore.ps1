<#
.SYNOPSIS
PS98-BackupRestore-125.ps1 - Backup and Restore for PS25 v3.0
#>

param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("Backup","Restore","Test")]
  [string]$Action,
  [Parameter(Mandatory=$true)][string]$ProjectPath,
  [Parameter(Mandatory=$true)][string]$RepoRoot,
  [Parameter(Mandatory=$true)][string]$ProjectName
)

$ErrorActionPreference = "Stop"
$BackupRoot = Join-Path $RepoRoot "demo-bank-backups"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"; TEST="Magenta"}[$Level]
  Write-Host "[$time] [$Level] PS98: $Msg" -ForegroundColor $color
}

function Backup-Project {
  param([string]$Source, [string]$ProjectName)
  if(!(Test-Path $Source)){ throw "Source path not found: $Source" }
  $timestamp = Get-Date -Format yyyyMMdd-HHmmss
  $ProjectBackupDir = Join-Path $BackupRoot $ProjectName
  if (-not (Test-Path $ProjectBackupDir)) { New-Item -ItemType Directory -Path $ProjectBackupDir -Force | Out-Null }
  $Dest = Join-Path $ProjectBackupDir "backup-$timestamp"
  Write-Log "BACKUP: $Source -> $ProjectBackupDir\backup-$timestamp" "INFO"

  $excludeDirs = "node_modules",".git","dist","build",".next","target","__pycache__",".venv","clickhouse_data","metabase_data"
  $excludeArgs = $excludeDirs | ForEach-Object { "/XD $_" }
  $robocopyArgs = @($Source, $Dest, "/E", "/NFL", "/NDL", "/NJH", "/NJS", "/R:0", "/W:0") + $excludeArgs
  Start-Process robocopy -ArgumentList $robocopyArgs -Wait -NoNewWindow
  if ($LASTEXITCODE -ge 8) { throw "Backup failed. Robocopy code: $LASTEXITCODE" }
  Write-Log "BACKUP: Complete. Code: $LASTEXITCODE" "SUCCESS"
  return $Dest
}

function Restore-Project {
  param([string]$Dest, [string]$ProjectName)
  $ProjectBackupDir = Join-Path $BackupRoot $ProjectName
  $LatestBackup = Get-ChildItem "$ProjectBackupDir\backup-*" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
  if (-not $LatestBackup) { throw "No backup found in $ProjectBackupDir to restore" }
  Write-Log "ROLLBACK: Restoring $Dest from $(Split-Path $LatestBackup -Leaf)" "WARN"
  Get-Process node, java, docker -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep 2
  $excludeDirs = "node_modules",".venv",".git","dist","build",".next","target","clickhouse_data","metabase_data"
  $excludeArgs = $excludeDirs | ForEach-Object { "/XD $_" }
  $robocopyArgs = @($LatestBackup, $Dest, "/E", "/NFL", "/NDL", "/NJH", "/NJS", "/R:0", "/W:0") + $excludeArgs
  Start-Process robocopy -ArgumentList $robocopyArgs -Wait -NoNewWindow
  if ($LASTEXITCODE -ge 8) { throw "Restore failed. Robocopy code: $LASTEXITCODE" }
  Write-Log "RESTORE: Complete - deps preserved" "SUCCESS"
}

if (-not (Test-Path $BackupRoot)) { New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null }

switch ($Action) {
  "Backup" { Backup-Project -Source $ProjectPath -ProjectName $ProjectName; exit 0 }
  "Restore" { Restore-Project -Dest $ProjectPath -ProjectName $ProjectName; exit 0 }
  "Test" { Write-Log "Use Test mode from old version if needed" "INFO"; exit 0 }
}