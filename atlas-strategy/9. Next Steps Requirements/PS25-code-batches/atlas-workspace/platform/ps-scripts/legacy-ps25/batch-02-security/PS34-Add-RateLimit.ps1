<#
.SYNOPSIS
PS25 Script: PS34-Add-RateLimit

.DESCRIPTION
INPUT: backend/pom.xml
PROCESSING: Adds Bucket4j. Creates RateLimitFilter 100 req/min per tenant_id
OUTPUT: 429 Too Many Requests when limit exceeded
HYPERLINK: https://github.com/vladimir-bukhtoyarov/bucket4j
STACK: Spring Boot + Bucket4j 7.6.0
COMPLIANCE: PS25 Tenant Fair Use Policy

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 2
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS34: Adding Bucket4j Rate Limit per tenant ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$rateDep = @"
    <dependency><groupId>com.github.vladimir-bukhtoyarov</groupId><artifactId>bucket4j-core</artifactId><version>7.6.0</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$rateDep`n</dependencies>" | Set-Content $pom

$rateFilter = Join-Path $BasePath "backend\src\main\java\com\demobank\filter\RateLimitFilter.java"
@"
package com.demobank.filter;
import io.github.bucket4j.Bucket; import io.github.bucket4j.Bandwidth;
import java.time.Duration; import java.util.Map; import java.util.concurrent.ConcurrentHashMap;
import jakarta.servlet.*; import jakarta.servlet.http.*;
public class RateLimitFilter implements Filter {
    private final Map<String, Bucket> cache = new ConcurrentHashMap<>();
    private Bucket createBucket() { return Bucket.builder().addLimit(Bandwidth.simple(100, Duration.ofMinutes(1))).build(); }
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws java.io.IOException, ServletException {
        String tenant = com.demobank.context.TenantContext.getTenantId().toString();
        Bucket bucket = cache.computeIfAbsent(tenant, k -> createBucket());
        if(bucket.tryConsume(1)) chain.doFilter(req,res);
        else ((HttpServletResponse)res).setStatus(429);
    }
}
"@ | Out-File -FilePath $rateFilter -Encoding utf8

Write-Host "PS34 Done: 100 req/min per tenant" -ForegroundColor Green
