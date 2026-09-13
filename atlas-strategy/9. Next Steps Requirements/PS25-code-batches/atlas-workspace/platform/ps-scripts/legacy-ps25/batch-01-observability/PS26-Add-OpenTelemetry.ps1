<#
.SYNOPSIS
PS25 Script: PS26-Add-OpenTelemetry

.DESCRIPTION
INPUT: backend/pom.xml
PROCESSING: Adds Micrometer OTel bridge + OTLP exporter. Creates TenantMdcFilter
OUTPUT: All logs/traces include tenant_id
HYPERLINK: https://micrometer.io/docs/tracing
STACK: Spring Boot 3.2 + Micrometer + OTel + SLF4J MDC
COMPLIANCE: PS25 Multi-Tenancy via TenantContext

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 1
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS26: Adding OpenTelemetry ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$otelDeps = @"
    <dependency><groupId>io.micrometer</groupId><artifactId>micrometer-tracing-bridge-otel</artifactId></dependency>
    <dependency><groupId>io.opentelemetry</groupId><artifactId>opentelemetry-exporter-otlp</artifactId></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$otelDeps`n</dependencies>" | Set-Content $pom

$filterPath = Join-Path $BasePath "backend\src\main\java\com\demobank\filter\TenantMdcFilter.java"
@"
package com.demobank.filter;
import org.slf4j.MDC; import jakarta.servlet.*; import java.io.IOException; import java.util.UUID;
public class TenantMdcFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        UUID tenantId = com.demobank.context.TenantContext.getTenantId();
        if(tenantId!= null) MDC.put("tenant_id", tenantId.toString());
        try { chain.doFilter(req, res); } finally { MDC.remove("tenant_id"); }
    }
}
"@ | Out-File -FilePath $filterPath -Encoding utf8
Write-Host "PS26 Done" -ForegroundColor Green
