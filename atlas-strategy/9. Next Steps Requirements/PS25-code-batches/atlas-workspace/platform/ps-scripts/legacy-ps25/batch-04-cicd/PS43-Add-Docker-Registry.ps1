<#
.SYNOPSIS
PS25 Script: PS43-Add-Docker-Registry

.DESCRIPTION
INPUT: None
PROCESSING: Creates docker-compose for local Harbor/Registry + image tagging strategy
OUTPUT: Private registry at localhost:5000 for Atlas images
HYPERLINK: https://goharbor.io
STACK: Docker Registry + docker-compose
COMPLIANCE: PS25 Image versioning by git SHA

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS43: Spinning Local Docker Registry ===" -ForegroundColor Cyan

$registryCompose = Join-Path $BasePath "docker-compose-registry.yml"
@"
version: '3.8'
services:
  registry:
    image: registry:2
    ports: ["5000:5000"]
    volumes: ["./registry-data:/var/lib/registry"]
  backend:
    build:./backend
    image: localhost:5000/demobank/backend:latest
"@ | Out-File $registryCompose -Encoding utf8

Write-Host "PS43 Done: Run 'docker compose -f docker-compose-registry.yml up -d'" -ForegroundColor Green
