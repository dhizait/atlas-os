<#
.SYNOPSIS
PS25 Script: BE-PS59-Update-Requirements

.DESCRIPTION
INPUT: pom.xml
PROCESSING: Adds spring-data-jpa, flyway-core, postgresql deps
OUTPUT: Updated pom.xml
HYPERLINK: https://maven.apache.org
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 1
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS59-Update-Requirements.ps1
# PURPOSE: Performs core PS25 automation task
# FILE: BE-PS59-Update-Requirements.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$pomFile = Join-Path $BeRoot "pom.xml"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS59: $Msg" -ForegroundColor $color
}

Write-Log "Updating pom.xml for PS25 multi-tenancy dependencies" "INFO"
if ($DryRun) { Write-Host "[PS59 DRY RUN] Would update $pomFile"; exit 0 }

if (-not (Test-Path $pomFile)) { throw "pom.xml not found at $pomFile" }
$backup = "$pomFile.bak_$(Get-Date -Format yyyyMMdd_HHmmss)"
Copy-Item $pomFile $backup; Write-Log "Backup: $backup" "SUCCESS"

[xml]$pom = Get-Content $pomFile
$deps = $pom.project.dependencies

@(
  @{g="org.springframework.boot";a="spring-boot-starter-data-jpa"},
  @{g="org.flywaydb";a="flyway-core"},
  @{g="org.postgresql";a="postgresql";scope="runtime"}
) | ForEach-Object {
    $exists = $deps.dependency | Where-Object { $_.groupId -eq $_.g -and $_.artifactId -eq $_.a }
    if(-not $exists){
        $dep = $pom.CreateElement("dependency")
        $g = $pom.CreateElement("groupId"); $g.InnerText = $_.g
        $a = $pom.CreateElement("artifactId"); $a.InnerText = $_.a
        $dep.AppendChild($g); $dep.AppendChild($a)
        $deps.AppendChild($dep)
    }
}
$pom.Save($pomFile)
Write-Log "PS59 Complete: pom.xml updated with JPA, Flyway, Postgres" "SUCCESS"; exit 0
