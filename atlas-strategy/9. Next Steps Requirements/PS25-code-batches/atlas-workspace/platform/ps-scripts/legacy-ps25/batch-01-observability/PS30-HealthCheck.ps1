<#
.SYNOPSIS PS25 Script: PS30-HealthCheck
.DESCRIPTION INPUT: None PROCESSING: Creates TenantHealthIndicator OUTPUT: /actuator/health shows tenantDb UP
.NOTES Generated: 2026-08-06 | BATCH 1
#>
param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
Write-Host "=== PS30: Adding Tenant-Aware HealthCheck ===" -ForegroundColor Cyan
... [rest of your PS30 code]...
Write-Host "PS30 Done" -ForegroundColor Green
