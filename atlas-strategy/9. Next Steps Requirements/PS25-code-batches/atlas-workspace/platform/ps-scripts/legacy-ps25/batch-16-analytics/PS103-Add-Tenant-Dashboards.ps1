<#
.SYNOPSIS
PS25 Script: PS103-Add-Tenant-Dashboards

.DESCRIPTION
INPUT: backend/
PROCESSING: API to serve pre-built charts per tenant from ClickHouse
OUTPUT: /api/analytics/dashboard returns KPI JSON
HYPERLINK: https://clickhouse.com/docs
STACK: Spring Boot + ClickHouse JDBC
COMPLIANCE: PS25 Per-tenant analytics

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 16
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS103: Adding Tenant Dashboards API ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$chDep = @"
    <dependency><groupId>com.clickhouse</groupId><artifactId>clickhouse-jdbc</artifactId><version>0.5.1</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$chDep`n</dependencies>" | Set-Content $pom

$analyticsCtrl = Join-Path $BasePath "backend\src\main\java\com\demobank\analytics\AnalyticsController.java"
@"
package com.demobank.analytics;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController @RequestMapping("/api/analytics")
public class AnalyticsController {
    private final JdbcTemplate chJdbc;
    public AnalyticsController(JdbcTemplate chJdbc) { this.chJdbc = chJdbc; }

    @GetMapping("/dashboard")
    public Map<String,Object> getDashboard(@RequestHeader("X-Tenant-ID") String tenantId) {
        String sql = "SELECT count() as vouchers_today, sum(amount) as volume FROM vouchers WHERE tenant_id =? AND toDate(created_at) = today()";
        return chJdbc.queryForMap(sql, tenantId);
    }
}
"@ | Out-File $analyticsCtrl -Encoding utf8

Write-Host "PS103 Done: GET /api/analytics/dashboard" -ForegroundColor Green
