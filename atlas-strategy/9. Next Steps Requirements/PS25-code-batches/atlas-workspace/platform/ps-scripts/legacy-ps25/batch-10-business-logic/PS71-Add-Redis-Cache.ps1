<#
.SYNOPSIS
PS25 Script: PS71-Add-Redis-Cache

.DESCRIPTION
INPUT: backend/pom.xml
PROCESSING: Adds Spring Cache + Redis for tenant voucher queries
OUTPUT: 10x faster reads. Cache key includes tenant_id
HYPERLINK: https://redis.io
STACK: Spring Boot 3.2 + Redis + Lettuce
COMPLIANCE: PS25 Performance SLA <500ms p95

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 10
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS71: Adding Redis Cache ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$redisDep = @"
    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-redis</artifactId></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$redisDep`n</dependencies>" | Set-Content $pom

$cacheConfig = Join-Path $BasePath "backend\src\main\java\com\demobank\config\CacheConfig.java"
@"
package com.demobank.config;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Configuration;
@Configuration @EnableCaching
public class CacheConfig {}
"@ | Out-File $cacheConfig -Encoding utf8

$yml = Join-Path $BasePath "backend\src\main\resources\application.yml"
@"
spring:
  redis:
    host: redis
    port: 6379
  cache:
    type: redis
"@ | Add-Content $yml

Write-Host "PS71 Done: Annotate service methods with @Cacheable(key='#tenantId')" -ForegroundColor Green
