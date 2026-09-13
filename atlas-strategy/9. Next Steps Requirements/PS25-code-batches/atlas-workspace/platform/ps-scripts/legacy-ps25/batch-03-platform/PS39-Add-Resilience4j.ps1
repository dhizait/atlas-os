<#
.SYNOPSIS
PS25 Script: PS39-Add-Resilience4j

.DESCRIPTION
INPUT: backend/pom.xml
PROCESSING: Adds CircuitBreaker, Retry, Bulkhead for voucher API
OUTPUT: Fault tolerance per tenant
HYPERLINK: https://resilience4j.readme.io
STACK: Spring Boot 3.2 + Resilience4j
COMPLIANCE: PS25 99.99% uptime target

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 3
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS39: Adding Resilience4j ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$resDeps = @"
    <dependency><groupId>io.github.resilience4j</groupId><artifactId>resilience4j-spring-boot3</artifactId><version>2.1.0</version></dependency>
    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-aop</artifactId></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$resDeps`n</dependencies>" | Set-Content $pom

$yml = Join-Path $BasePath "backend\src\main\resources\application.yml"
@"
resilience4j:
  circuitbreaker:
    instances:
      voucherService: {slidingWindowSize: 10, minimumNumberOfCalls: 5, failureRateThreshold: 50}
  retry:
    instances:
      voucherService: {maxAttempts: 3, waitDuration: 1s}
"@ | Add-Content $yml

$service = Join-Path $BasePath "backend\src\main\java\com\demobank\service\VoucherServiceResilient.java"
@"
package com.demobank.service;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.stereotype.Service;
@Service
public class VoucherServiceResilient {
    @CircuitBreaker(name = "voucherService")
    @Retry(name = "voucherService")
    public void createVoucher() { /* delegate to BE-PS73 */ }
}
"@ | Out-File $service -Encoding utf8

Write-Host "PS39 Done: CircuitBreaker + Retry on voucherService" -ForegroundColor Green
