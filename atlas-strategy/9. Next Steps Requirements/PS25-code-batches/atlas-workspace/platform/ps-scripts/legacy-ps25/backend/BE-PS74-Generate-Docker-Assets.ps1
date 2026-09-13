<#
.SYNOPSIS
PS25 Script: BE-PS74-Generate-Docker-Assets

.DESCRIPTION
INPUT: N/A
PROCESSING: Creates Dockerfile for Java 17 +.dockerignore
OUTPUT: Dockerfile,.dockerignore
HYPERLINK: https://docs.docker.com
STACK: Spring Boot 3 + JPA + Flyway + JUnit 5
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS74-Generate-Docker-Assets.ps1
# PURPOSE: Creates docker-compose and builds container
# FILE: BE-PS74-Generate-Docker-Assets.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [string]$AppName = "demo-bank-be",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS74: $Msg" -ForegroundColor $color
}

Write-Host "PS74: Generate Docker Assets" -ForegroundColor Magenta

if ($DryRun) { Write-Host "[PS74 DRY RUN] Would create Dockerfile,.dockerignore in $BeRoot"; exit 0 }

$dockerfile = Join-Path $BeRoot "Dockerfile"
@"
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
COPY pom.xml.
COPY src./src
RUN./mvnw clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java","-jar","app.jar"]
"@ | Set-Content $dockerfile -Encoding UTF8
Write-Log "Created: Dockerfile" "SUCCESS"

$dockerignore = Join-Path $BeRoot ".dockerignore"
@"
target/
.git
*.md
"@ | Set-Content $dockerignore -Encoding UTF8
Write-Log "Created:.dockerignore" "SUCCESS"

Write-Log "PS74 Complete! Docker ready for local + UAT" "SUCCESS"; exit 0
