<#
.SYNOPSIS PS25 Script: PS28-Add-JsonLogging
.DESCRIPTION INPUT: pom.xml PROCESSING: Adds logstash encoder + logback-spring.xml OUTPUT: JSON logs with tenant_id
.NOTES Generated: 2026-08-06 | BATCH 1
#>
param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
Write-Host "=== PS28: Adding JSON Logging ===" -ForegroundColor Cyan
... [rest of your PS28 code]...
Write-Host "PS28 Done" -ForegroundColor Green
