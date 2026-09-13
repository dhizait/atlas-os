<#
.SYNOPSIS
PS25 Script: BE-PS71-Create-Voucher-Controller

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates VoucherController.java + VoucherDTO
OUTPUT: src/main/java/com/demobank/controller/VoucherController.java
HYPERLINK: https://spring.io/guides
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 5
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS71-Create-Voucher-Controller.ps1
# PURPOSE: Performs core PS25 automation task
# FILE: BE-PS71-Create-Voucher-Controller.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$controllerPath = Join-Path $BeRoot "src\main\java\com\demobank\controller\VoucherController.java"
$dtoPath = Join-Path $BeRoot "src\main\java\com\demobank\dto\VoucherDTO.java"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS71: $Msg" -ForegroundColor $color
}

Write-Log "Creating Voucher REST Controller with tenant isolation" "INFO"
if ($DryRun) { Write-Host "[PS71 DRY RUN] Would create $controllerPath"; exit 0 }

New-Item -ItemType Directory -Path (Split-Path $controllerPath) -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path $dtoPath) -Force | Out-Null

@'
package com.demobank.dto;

public record VoucherDTO(Long id, Double amount, java.util.UUID tenantId) {}
'@ | Set-Content -Path $dtoPath -Encoding UTF8

@'
package com.demobank.controller;

import com.demobank.config.TenantContext;
import com.demobank.domain.Voucher;
import com.demobank.dto.VoucherDTO;
import com.demobank.repository.VoucherRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/vouchers")
public class VoucherController {

    private final VoucherRepository repository;

    public VoucherController(VoucherRepository repository) { this.repository = repository; }

    @GetMapping
    public List<VoucherDTO> getVouchers() {
        UUID tenantId = TenantContext.getTenantId();
        return repository.findByTenantId(tenantId).stream()
              .map(v -> new VoucherDTO(v.getId(), v.getAmount(), v.getTenantId())).toList();
    }

    @PostMapping
    public ResponseEntity<VoucherDTO> createVoucher(@RequestBody VoucherDTO dto) {
        UUID tenantId = TenantContext.getTenantId();
        Voucher v = new Voucher();
        v.setAmount(dto.amount());
        v.setTenantId(tenantId);
        Voucher saved = repository.save(v);
        return ResponseEntity.status(201).body(new VoucherDTO(saved.getId(), saved.getAmount(), saved.getTenantId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<VoucherDTO> getVoucher(@PathVariable Long id) {
        UUID tenantId = TenantContext.getTenantId();
        return repository.findByIdAndTenantId(id, tenantId)
              .map(v -> ResponseEntity.ok(new VoucherDTO(v.getId(), v.getAmount(), v.getTenantId())))
              .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVoucher(@PathVariable Long id) {
        UUID tenantId = TenantContext.getTenantId();
        repository.findByIdAndTenantId(id, tenantId).ifPresent(repository::delete);
        return ResponseEntity.noContent().build();
    }
}
'@ | Set-Content -Path $controllerPath -Encoding UTF8

Write-Log "PS71 Complete: VoucherController.java + VoucherDTO created" "SUCCESS"; exit 0
