<#
.SYNOPSIS PS25 Script: PS29-Docker-Observability
.DESCRIPTION INPUT: None PROCESSING: Creates docker-compose-obs.yml + prometheus.yml OUTPUT: Grafana+Prom+Tempo stack
.NOTES Generated: 2026-08-06 | BATCH 1
#>
param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
Write-Host "=== PS29: Spinning Observability Stack ===" -ForegroundColor Cyan
$compose = Join-Path $BasePath "docker-compose-obs.yml"
... [rest of your PS29 code]...
Write-Host "PS29 Done" -ForegroundColor Green
