<#
.SYNOPSIS
PS25 Script: BE-PS79-Create-Voucher-Tests

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates VoucherControllerTest.java with MockMvc
OUTPUT: Controller integration test
HYPERLINK:
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 7
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS79-Create-Voucher-Tests.ps1
# PURPOSE: Runs unit/integration tests for tenant isolation
# FILE: BE-PS79-Create-Voucher-Tests.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$testPath = Join-Path $BeRoot "src\test\java\com\demobank\controller\VoucherControllerTest.java"
$testDir = Split-Path $testPath -Parent

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"; $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS79: $Msg" -ForegroundColor $color
}

Write-Log "PS79: Creating VoucherController integration test" "INFO"
if ($DryRun) { Write-Host "[PS79 DRY RUN] Would create $testPath"; exit 0 }
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

@'
package com.demobank.controller;

import com.demobank.util.TenantTestUtil;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class VoucherControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testGetAllVouchersRequiresTenantHeader() throws Exception {
        mockMvc.perform(get("/api/v1/vouchers"))
           .andExpect(status().isUnauthorized());
    }

    @Test
    void testCreateVoucherWithTenantHeader() throws Exception {
        UUID tenantId = TenantTestUtil.createTestTenant();
        String json = "{\"amount\":100.0}";
        mockMvc.perform(post("/api/v1/vouchers")
           .header("X-Tenant-ID", tenantId)
           .contentType(MediaType.APPLICATION_JSON)
           .content(json))
           .andExpect(status().isCreated());
    }

    @Test
    void testGetVoucherCrossTenant403() throws Exception {
        UUID tenantA = TenantTestUtil.createTestTenant();
        String res = mockMvc.perform(post("/api/v1/vouchers")
           .header("X-Tenant-ID", tenantA)
           .content("{\"amount\":50}").contentType(MediaType.APPLICATION_JSON))
           .andReturn().getResponse().getContentAsString();

        UUID tenantB = TenantTestUtil.createTestTenant();
        mockMvc.perform(get("/api/v1/vouchers/1")
           .header("X-Tenant-ID", tenantB))
           .andExpect(status().isNotFound()); // 404 because not found for tenantB
    }
}
'@ | Set-Content -Path $testPath -Encoding UTF8

Write-Log "PS79 Complete: VoucherControllerTest.java created" "SUCCESS"; exit 0
