<#
.SYNOPSIS
PS25 Script: FE-PS49-Docker-Build

.DESCRIPTION
INPUT: Dockerfile, nginx.conf
PROCESSING: `docker compose build --no-cache`
OUTPUT: Built FE image
HYPERLINK: https://docs.docker.com
STACK: React 18 + Vite + TypeScript + Docker
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 2
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\frontend\FE-PS49-Docker-Build.ps1
# PURPOSE: Creates docker-compose and builds container
# FILE: FE-PS49-Docker-Build.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$Force,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$fePath = Join-Path $BasePath "frontend"
$composeFile = Join-Path $fePath "docker-compose.yml"
$nginxFile = Join-Path $fePath "nginx.conf"
$Dockerfile = Join-Path $fePath "Dockerfile"

function Write-Log {
  param([string]$Message, [string]$Level = "INFO")
  $timestamp = Get-Date -Format "HH:mm:ss"
  $color = switch($Level) { "SUCCESS" { "Green" } "ERROR" { "Red" } "WARN" { "Yellow" } default { "Cyan" } }
  Write-Host "[$timestamp] [$Level] [PS49] $Message" -ForegroundColor $color
}

if (-not (Test-Path $fePath)) { Write-Log "FE folder not found at $fePath" "ERROR"; exit 1 }
Set-Location $fePath

if ($DryRun) { Write-Host "[PS49 DRY RUN] Would generate docker files and build"; exit 0 }

# Generate if missing
if (-not (Test-Path $Dockerfile)) {
@'
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json./
RUN npm ci
COPY..
RUN npm run build
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
'@ | Set-Content $Dockerfile -Encoding UTF8
}

if (-not (Test-Path $nginxFile)) {
@'
server { listen 80; location / { root /usr/share/nginx/html; try_files $uri $uri/ /index.html; } }
'@ | Set-Content $nginxFile -Encoding UTF8
}

if (-not (Test-Path $composeFile)) {
@'
services:
  frontend:
    build:.
    ports: ["3000:80"]
    env_file: [.env]
'@ | Set-Content $composeFile -Encoding UTF8
}

Write-Log "Building docker image via compose..." "INFO"
$args = @("compose","build")
if($Force){ $args += "--no-cache" }
& docker $args
if ($LASTEXITCODE -ne 0) { Write-Log "Docker build failed" "ERROR"; exit 1 }

Write-Log "PS49 Complete: Build done" "SUCCESS"; exit 0
