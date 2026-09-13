<#
.SYNOPSIS PS25 Script: PS27-Add-Metrics
.DESCRIPTION INPUT: pom.xml PROCESSING: Adds Actuator + Prometheus OUTPUT: /actuator/prometheus with tenant tags
.NOTES Generated: 2026-08-06 | BATCH 1
#>
param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
Write-Host "=== PS27: Adding Prometheus Metrics ===" -ForegroundColor Cyan
... [rest of your PS27 code with Join-Path $BasePath]...
Write-Host "PS27 Done" -ForegroundColor Green
