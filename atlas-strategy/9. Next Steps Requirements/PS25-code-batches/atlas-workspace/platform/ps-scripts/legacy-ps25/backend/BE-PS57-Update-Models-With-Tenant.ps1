<#
.SYNOPSIS
PS25 Script: BE-PS57-Update-Models-With-Tenant

.DESCRIPTION
INPUT: entity.java files
PROCESSING: Creates TenantBase.java with tenantId, makes entities extend it
OUTPUT: src/main/java/com/demobank/domain/TenantBase.java
HYPERLINK: https://docs.jboss.org/hibernate
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 1
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS57-Update-Models-With-Tenant.ps1
# PURPOSE: Updates JPA entities with tenantId field
# FILE: BE-PS57-Update-Models-With-Tenant.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$modelDir = Join-Path $BeRoot "src\main\java\com\demobank\domain"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS57: $Msg" -ForegroundColor $color
}

Write-Log "Updating JPA entities to extend TenantBase with tenantId" "INFO"

if (-not (Test-Path $modelDir)) { New-Item -ItemType Directory -Path $modelDir -Force | Out-Null }

if ($DryRun) { Write-Host "[PS57 DRY RUN] Would create TenantBase.java and update entities in $modelDir"; exit 0 }

$tenantBaseFile = Join-Path $modelDir "TenantBase.java"
if (Test-Path $tenantBaseFile) {
  $backup = "$tenantBaseFile.bak_$(Get-Date -Format yyyyMMdd_HHmmss)"
  Copy-Item $tenantBaseFile $backup; Write-Log "Backup: $backup" "SUCCESS"
}

@'
package com.demobank.domain;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import java.util.UUID;

@MappedSuperclass
public abstract class TenantBase {
    @Column(name = "tenant_id", nullable = false, columnDefinition = "UUID")
    private UUID tenantId;

    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }
}
'@ | Set-Content $tenantBaseFile -Encoding UTF8
Write-Log "Created TenantBase.java" "SUCCESS"

# Update existing entities to extend TenantBase
@("Voucher","Transaction","Account") | ForEach-Object {
    $f = Join-Path $modelDir "$_.java"
    if(Test-Path $f){
        (Get-Content $f -Raw) -replace 'public class', 'public class $_ extends TenantBase' | Set-Content $f
        Write-Log "Updated $_.java" "INFO"
    }
}

Write-Log "PS57 Complete: JPA models updated" "SUCCESS"; exit 0
