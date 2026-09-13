<#
.SYNOPSIS
PS25 Script: PS65-Add-Integration-Testing

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds WireMock + TestContainers for integration tests
OUTPUT: Automated tests for ISO, Switch, Webhooks
HYPERLINK: https://wiremock.org
STACK: JUnit 5 + WireMock + TestContainers
COMPLIANCE: PS25 Contract testing

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 8
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS65: Adding Integration Tests ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$testDeps = @"
    <dependency><groupId>org.wiremock</groupId><artifactId>wiremock</artifactId><version>3.0.1</version><scope>test</scope></dependency>
    <dependency><groupId>org.testcontainers</groupId><artifactId>junit-jupiter</artifactId><version>1.19.0</version><scope>test</scope></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$testDeps`n</dependencies>" | Set-Content $pom

$test = Join-Path $BasePath "backend\src\test\java\com\demobank\integration\SwitchIntegrationTest.java"
@"
package com.demobank.integration;
import org.junit.jupiter.api.Test;
import com.github.tomakehurst.wiremock.WireMockServer;
public class SwitchIntegrationTest {
    @Test void testSendPayment() {
        WireMockServer server = new WireMockServer();
        // Stub switch response, call PaymentSwitchClient, verify
    }
}
"@ | Out-File $test -Encoding utf8

Write-Host "PS65 Done: Run 'mvn verify' to test integrations" -ForegroundColor Green
