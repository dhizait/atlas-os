<#
.SYNOPSIS
PS25 Script: PS96-Add-OpenAPI-Docs

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds Springdoc OpenAPI + tenant_id header docs
OUTPUT: Swagger UI at /swagger-ui.html with multi-tenant examples
HYPERLINK: https://springdoc.org
STACK: Spring Boot 3.2 + springdoc-openapi
COMPLIANCE: PS25 API documentation

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 15
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS96: Adding OpenAPI Docs ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$openapiDep = @"
    <dependency><groupId>org.springdoc</groupId><artifactId>springdoc-openapi-starter-webmvc-ui</artifactId><version>2.3.0</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$openapiDep`n</dependencies>" | Set-Content $pom

$openapiCfg = Join-Path $BasePath "backend\src\main\java\com\demobank\config\OpenApiConfig.java"
@"
package com.demobank.config;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.parameters.Parameter;
@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI().addServersItem(new io.swagger.v3.oas.models.servers.Server().url("/"))
           .components(new io.swagger.v3.oas.models.Components()
           .addParameters("tenantId", new Parameter().in("header").name("X-Tenant-ID").required(true)));
    }
}
"@ | Out-File $openapiCfg -Encoding utf8

Write-Host "PS96 Done: Swagger UI at http://localhost:8080/swagger-ui.html" -ForegroundColor Green
