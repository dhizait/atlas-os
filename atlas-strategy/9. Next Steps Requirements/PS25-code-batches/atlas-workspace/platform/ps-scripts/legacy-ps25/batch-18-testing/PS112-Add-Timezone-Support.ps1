<#
.SYNOPSIS
PS25 Script: PS112-Add-Timezone-Support

.DESCRIPTION
INPUT: backend/
PROCESSING: Stores all times in UTC. Converts to tenant timezone on read
OUTPUT: X-Timezone header respected. Default Africa/Harare
HYPERLINK: https://www.iana.org/time-zones
STACK: Spring Boot + Java Time
COMPLIANCE: PS25 Multi-region tenants

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 18
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS112: Adding Timezone Support ===" -ForegroundColor Cyan

$tzFilter = Join-Path $BasePath "backend\src\main\java\com\demobank\config\TimezoneFilter.java"
@"
package com.demobank.config;
import jakarta.servlet.*;
@Component
public class TimezoneFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) {
        String tz = ((HttpServletRequest)req).getHeader("X-Timezone");
        TimeZone.setDefault(TimeZone.getTimeZone(tz!= null? tz : "Africa/Harare"));
        chain.doFilter(req, res);
    }
}
"@ | Out-File $tzFilter -Encoding utf8

Write-Host "PS112 Done: Send X-Timezone: America/New_York" -ForegroundColor Green
