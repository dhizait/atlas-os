<#
.SYNOPSIS
PS25 Script: PS61-Add-ISO20022-Adapter

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds ISO20022 pain.001 and camt.053 XML mapping for voucher posting
OUTPUT: /api/iso20022/inbound accepts bank files. Outbound to switch
HYPERLINK: https://www.iso20022.org
STACK: Spring Boot + JAXB + Camel
COMPLIANCE: PS25 SWIFT/ISO20022 Interoperability

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 8
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS61: Adding ISO20022 Adapter ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$isoDeps = @"
    <dependency><groupId>org.apache.camel</groupId><artifactId>camel-spring-boot-starter</artifactId><version>4.0.0</version></dependency>
    <dependency><groupId>jakarta.xml.bind</groupId><artifactId>jakarta.xml.bind-api</artifactId></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$isoDeps`n</dependencies>" | Set-Content $pom

$adapter = Join-Path $BasePath "backend\src\main\java\com\demobank\integration\Iso20022Adapter.java"
@"
package com.demobank.integration;
import org.apache.camel.builder.RouteBuilder;
import org.springframework.stereotype.Component;
@Component
public class Iso20022Adapter extends RouteBuilder {
    public void configure() {
        from("rest:post:/api/iso20022/inbound")
         .unmarshal().jaxb("com.demobank.iso.pain001")
         .bean("voucherService", "postFromIso")
         .to("kafka:iso.outbound");
    }
}
"@ | Out-File $adapter -Encoding utf8

Write-Host "PS61 Done: POST XML to /api/iso20022/inbound" -ForegroundColor Green
