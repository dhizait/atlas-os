<#
.SYNOPSIS
PS25 Script: BE-PS72-Generate-Test-Suite

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates VoucherServiceTest + ControllerIntegrationTest
OUTPUT: 2 JUnit test files
HYPERLINK: https://spring.io/guides
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS72-Generate-Test-Suite.ps1
# PURPOSE: Runs unit/integration tests for tenant isolation
# FILE: BE-PS72-Generate-Test-Suite.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$testDir = Join-Path $BeRoot "src\test\java\com\demobank\service"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS72: $Msg" -ForegroundColor $color
}

Write-Host "================================================" -ForegroundColor Magenta
Write-Host " PS72: Generate JUnit Test Suite" -ForegroundColor Magenta
Write-Host " Output: $testDir" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta

if ($DryRun) { Write-Host "[PS72 DRY RUN] Would create 2 test files in $testDir"; exit 0 }
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

$testPath = Join-Path $testDir "VoucherServiceTest.java"
@'
package com.demobank.service;

import com.demobank.domain.Voucher;
import com.demobank.dto.VoucherDTO;
import com.demobank.repository.VoucherRepository;
import com.demobank.util.TenantTestUtil;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class VoucherServiceTest {

    @Autowired
    private VoucherService voucherService;

    @Test
    void testCreateVoucherWithTenant() {
        UUID tenantId = TenantTestUtil.createTestTenant();
        VoucherDTO dto = new VoucherDTO(null, 100.0, tenantId);
        VoucherDTO saved = voucherService.create(dto, tenantId);
        assertNotNull(saved.id());
        assertEquals(tenantId, saved.tenantId());
    }

    @Test
    void testFindByTenant() {
        UUID tenantId = TenantTestUtil.createTestTenant();
        var vouchers = voucherService.findAllByTenant(tenantId);
        assertNotNull(vouchers);
    }
}
'@ | Set-Content $testPath -Encoding UTF8
Write-Log "Created: VoucherServiceTest.java" "SUCCESS"

$intTestPath = Join-Path $testDir "VoucherControllerIntegrationTest.java"
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
public class VoucherControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testGetVouchersWithTenant() throws Exception {
        UUID tenantId = TenantTestUtil.createTestTenant();
        mockMvc.perform(get("/api/v1/vouchers").header("X-Tenant-ID", tenantId))
             .andExpect(status().isOk());
    }

    @Test
    void testGetVouchersWithoutTenant() throws Exception {
        mockMvc.perform(get("/api/v1/vouchers"))
             .andExpect(status().isUnauthorized());
    }

    @Test
    void testCreateVoucherWithTenant() throws Exception {
        UUID tenantId = TenantTestUtil.createTestTenant();
        String json = "{\"amount\":200}";
        mockMvc.perform(post("/api/v1/vouchers")
             .header("X-Tenant-ID", tenantId)
             .contentType(MediaType.APPLICATION_JSON)
             .content(json))
             .andExpect(status().isCreated());
    }
}
'@ | Set-Content $intTestPath -Encoding UTF8
Write-Log "Created: VoucherControllerIntegrationTest.java" "SUCCESS"

Write-Log "PS72 Complete! JUnit tests with tenant headers" "SUCCESS"; exit 0
