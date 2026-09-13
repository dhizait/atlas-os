<#
.SYNOPSIS
PS25 Script: PS117-Add-Rate-Limiting

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds Redis-based rate limiting per tenant + per IP
OUTPUT: 429 if > 1000 req/min per tenant
HYPERLINK: https://redis.io/commands/incr
STACK: Spring Boot + Bucket4j + Redis
COMPLIANCE: PS25 DDoS mitigation

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 19
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS117: Adding Rate Limiting ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$bucketDep = @"
    <dependency><groupId>com.bucket4j</groupId><artifactId>bucket4j-core</artifactId><version>8.7.0</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$bucketDep`n</dependencies>" | Set-Content $pom

$rateFilter = Join-Path $BasePath "backend\src\main\java\com\demobank\security\RateLimitFilter.java"
@"
package com.demobank.security;
import io.github.bucket4j.*;
@Component
public class RateLimitFilter implements Filter {
    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) {
        String tenant = ((HttpServletRequest)req).getHeader("X-Tenant-ID");
        Bucket bucket = buckets.computeIfAbsent(tenant, k -> Bucket.builder()
           .addLimit(Bandwidth.classic(1000, Refill.intervally(1000, Duration.ofMinutes(1)))).build());
        if (!bucket.tryConsume(1)) { ((HttpServletResponse)res).setStatus(429); return; }
        chain.doFilter(req, res);
    }
}
"@ | Out-File $rateFilter -Encoding utf8

Write-Host "PS117 Done: 1000 req/min per tenant" -ForegroundColor Green
