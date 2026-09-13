<#
.SYNOPSIS
PS25 Script: PS75-Add-APM-Tracing

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds Elastic APM agent for method-level tracing
OUTPUT: Trace every DB call + external API with tenant_id tag
HYPERLINK: https://www.elastic.co/apm
STACK: Elastic APM + Kibana
COMPLIANCE: PS25 Observability p95 breakdown

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 10
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS75: Adding APM Tracing ===" -ForegroundColor Cyan

$apmCompose = Join-Path $BasePath "docker-compose-apm.yml"
@"
version: '3.8'
services:
  apm-server:
    image: docker.elastic.co/apm/apm-server:8.12.0
    ports: ["8200:8200"]
  backend:
    environment:
      JAVA_TOOL_OPTIONS: "-javaagent:/apm/elastic-apm-agent.jar
        -Delastic.apm.service_name=demo-bank
        -Delastic.apm.server_urls=http://apm-server:8200
        -Delastic.apm.global_labels=tenant_id"
"@ | Out-File $apmCompose -Encoding utf8

Write-Host "PS75 Done: APM at http://localhost:5601/app/apm" -ForegroundColor Green
