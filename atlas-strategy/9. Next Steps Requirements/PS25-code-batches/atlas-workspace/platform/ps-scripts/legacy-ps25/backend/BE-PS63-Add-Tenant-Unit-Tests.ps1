<#
.SYNOPSIS
PS25 Script: BE-PS63-Add-Tenant-Unit-Tests

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates TenantIsolationTest.java
OUTPUT: src/test/java/com/demobank/service/TenantIsolationTest.java
HYPERLINK: https://junit.org
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS63-Add-Tenant-Unit-Tests.ps1
# PURPOSE: Implements multi-tenancy context and isolation
# FILE: BE-PS63-Add-Tenant-Unit-Tests.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$testDir = Join-Path $BeRoot "src\test\java\com\demobank\service"
$testFile = Join-Path $testDir "TenantIsolationTest.java"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS63: $Msg" -ForegroundColor $color
}

Write-Log "Adding JUnit tests for tenant isolation" "INFO"
if (-not (Test-Path $testDir)) { New-Item -ItemType Directory -Path $testDir -Force | Out-Null }

if ($DryRun) { Write-Host "[PS63 DRY RUN] Would write to $testFile"; exit 0 }

@'
package com.demobank.service;

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
public class TenantIsolationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testTenantIsolation() throws Exception {
        UUID tenantA = TenantTestUtil.createTestTenant();
        UUID tenantB = TenantTestUtil.createTestTenant();

        // Create voucher for tenantA
        mockMvc.perform(post("/api/v1/vouchers")
              .header("X-Tenant-ID", tenantA)
              .contentType(MediaType.APPLICATION_JSON)
              .content("{\"amount\":100}"))
              .andExpect(status().isOk());

        // tenantB should see 0 vouchers
        mockMvc.perform(get("/api/v1/vouchers")
              .header("X-Tenant-ID", tenantB))
              .andExpect(status().isOk())
              .andExpect(content().json("[]"));
    }

    @Test
    void testMissingTenantHeaderReturns401() throws Exception {
        mockMvc.perform(get("/api/v1/vouchers"))
              .andExpect(status().isUnauthorized());
    }
}
'@ | Set-Content $testFile -Encoding UTF8

Write-Log "PS63 Complete: JUnit tests added for tenant isolation" "SUCCESS"; exit 0
