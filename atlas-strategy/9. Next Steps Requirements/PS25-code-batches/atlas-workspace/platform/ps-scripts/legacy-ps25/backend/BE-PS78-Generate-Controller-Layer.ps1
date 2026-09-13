<#
.SYNOPSIS
PS25 Script: BE-PS78-Generate-Controller-Layer

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates DemoBankApplication.java + VoucherRepository
OUTPUT: Application entry + JPA Repo
HYPERLINK: https://spring.io
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 7
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS78-Generate-Controller-Layer.ps1
# PURPOSE: Performs core PS25 automation task
# FILE: BE-PS78-Generate-Controller-Layer.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$appDir = Join-Path $BeRoot "src\main\java\com\demobank"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS78: $Msg" -ForegroundColor $color
}

Write-Host "PS78: Generate Spring Boot Application entry point" -ForegroundColor Magenta
if ($DryRun) { Write-Host "[PS78 DRY RUN] Would create DemoBankApplication.java"; exit 0 }

New-Item -ItemType Directory -Path "$appDir\controller", "$appDir\service", "$appDir\repository", "$appDir\dto" -Force | Out-Null

# Create main SpringBootApplication
$mainPath = Join-Path $appDir "DemoBankApplication.java"
@'
package com.demobank;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoBankApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoBankApplication.class, args);
    }
}
'@ | Set-Content $mainPath -Encoding UTF8

# Create Repository
$repoPath = Join-Path $appDir "repository\VoucherRepository.java"
@'
package com.demobank.repository;

import com.demobank.domain.Voucher;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VoucherRepository extends JpaRepository<Voucher, Long> {
    List<Voucher> findByTenantId(UUID tenantId);
    Optional<Voucher> findByIdAndTenantId(Long id, UUID tenantId);
}
'@ | Set-Content $repoPath -Encoding UTF8

Write-Log "PS78 Complete! Application + Repository initialized" "SUCCESS"; exit 0
