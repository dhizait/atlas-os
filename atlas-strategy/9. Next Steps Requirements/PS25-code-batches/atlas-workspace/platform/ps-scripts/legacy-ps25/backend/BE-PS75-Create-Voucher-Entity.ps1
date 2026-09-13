<#
.SYNOPSIS
PS25 Script: BE-PS75-Create-Voucher-Entity

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates Voucher.java extends TenantBase
OUTPUT: src/main/java/com/demobank/domain/Voucher.java
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS75-Create-Voucher-Entity.ps1
# PURPOSE: Performs core PS25 automation task
# FILE: BE-PS75-Create-Voucher-Entity.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$entityPath = Join-Path $BeRoot "src\main\java\com\demobank\domain\Voucher.java"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"; $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS75: $Msg" -ForegroundColor $color
}

Write-Log "Creating Voucher entity extending TenantBase" "INFO"
if ($DryRun) { Write-Host "[PS75 DRY RUN] Would create $entityPath"; exit 0 }

New-Item -ItemType Directory -Path (Split-Path $entityPath) -Force | Out-Null

@'
package com.demobank.domain;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "vouchers", indexes = @Index(name = "ix_vouchers_tenant_id", columnList = "tenant_id"))
public class Voucher extends TenantBase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Double amount;

    @Column(length = 100)
    private String code;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    // getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
'@ | Set-Content -Path $entityPath -Encoding UTF8

Write-Log "PS75 Complete: Voucher.java entity created" "SUCCESS"; exit 0
