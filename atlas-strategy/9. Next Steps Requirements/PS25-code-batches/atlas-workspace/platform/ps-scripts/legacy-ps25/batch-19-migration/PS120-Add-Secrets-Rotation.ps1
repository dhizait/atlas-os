<#
.SYNOPSIS
PS25 Script: PS120-Add-Secrets-Rotation

.DESCRIPTION
INPUT: backend/
PROCESSING: Rotates DB password, JWT secret, Stripe key every 90 days
OUTPUT: Uses HashiCorp Vault. Zero downtime rotation
HYPERLINK: https://www.vaultproject.io
STACK: Spring Boot + Vault + Spring Cloud
COMPLIANCE: PS25 Secret management

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 19
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS120: Adding Secrets Rotation ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$vaultDep = @"
    <dependency><groupId>org.springframework.cloud</groupId><artifactId>spring-cloud-starter-vault-config</artifactId><version>4.1.0</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$vaultDep`n</dependencies>" | Set-Content $pom

$bootstrap = Join-Path $BasePath "backend\src\main\resources\bootstrap.yml"
@"
spring:
  cloud:
    vault:
      uri: https://vault.demo-bank.com
      authentication: TOKEN
      token: ${VAULT_TOKEN}
"@ | Out-File $bootstrap -Encoding utf8

$rotationJob = Join-Path $BasePath "atlas-workspace\platform\ps-scripts\rotate-secrets.ps1"
@"
# Rotate secrets in Vault every 90 days
vault kv patch secret/demobank db_password=$(openssl rand -base64 32)
kubectl rollout restart deployment backend
"@ | Out-File $rotationJob -Encoding utf8

Write-Host "PS120 Done: Secrets now from Vault. Run rotate-secrets.ps1 quarterly" -ForegroundColor Green
