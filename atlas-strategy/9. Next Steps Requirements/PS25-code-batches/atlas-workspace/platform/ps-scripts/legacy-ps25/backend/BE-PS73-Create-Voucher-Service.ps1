<#
.SYNOPSIS
PS25 Script: BE-PS73-Create-Voucher-Service

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates VoucherService with tenant-aware repo calls
OUTPUT: src/main/java/com/demobank/service/VoucherService.java
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS73-Create-Voucher-Service.ps1
# PURPOSE: Performs core PS25 automation task
# FILE: BE-PS73-Create-Voucher-Service.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$servicePath = Join-Path $BeRoot "src\main\java\com\demobank\service\VoucherService.java"
$serviceDir = Split-Path $servicePath -Parent

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"; $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS73: $Msg" -ForegroundColor $color
}

Write-Log "Creating VoucherService with tenant-aware repo" "INFO"
if ($DryRun) { Write-Host "[PS73 DRY RUN] Would create $servicePath"; exit 0 }
New-Item -ItemType Directory -Path $serviceDir -Force | Out-Null

@'
package com.demobank.service;

import com.demobank.domain.Voucher;
import com.demobank.dto.VoucherDTO;
import com.demobank.repository.VoucherRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.UUID;

@Service
public class VoucherService {
    private final VoucherRepository repository;

    public VoucherService(VoucherRepository repository) { this.repository = repository; }

    public List<VoucherDTO> findAllByTenant(UUID tenantId) {
        return repository.findByTenantId(tenantId).stream()
             .map(v -> new VoucherDTO(v.getId(), v.getAmount(), v.getTenantId()))
             .toList();
    }

    public VoucherDTO create(VoucherDTO dto, UUID tenantId) {
        Voucher v = new Voucher();
        v.setAmount(dto.amount());
        v.setTenantId(tenantId);
        Voucher saved = repository.save(v);
        return new VoucherDTO(saved.getId(), saved.getAmount(), saved.getTenantId());
    }

    public VoucherDTO findById(Long voucherId, UUID tenantId) {
        return repository.findByIdAndTenantId(voucherId, tenantId)
             .map(v -> new VoucherDTO(v.getId(), v.getAmount(), v.getTenantId()))
             .orElse(null);
    }

    public boolean delete(Long voucherId, UUID tenantId) {
        return repository.findByIdAndTenantId(voucherId, tenantId)
             .map(v -> { repository.delete(v); return true; })
             .orElse(false);
    }
}
'@ | Set-Content -Path $servicePath -Encoding UTF8

Write-Log "PS73 Complete: VoucherService.java created" "SUCCESS"; exit 0
