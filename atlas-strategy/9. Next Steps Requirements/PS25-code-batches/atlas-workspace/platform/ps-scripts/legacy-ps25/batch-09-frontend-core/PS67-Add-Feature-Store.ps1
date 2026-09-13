<#
.SYNOPSIS
PS25 Script: PS67-Add-Feature-Store

.DESCRIPTION
INPUT: docker-compose.yml
PROCESSING: Adds Feast feature store + Redis online store
OUTPUT: Real-time features: vouchers_24h_count, avg_amount per tenant
HYPERLINK: https://feast.dev
STACK: Feast + Redis + Kafka
COMPLIANCE: PS25 ML feature consistency

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 9
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS67: Adding Feature Store ===" -ForegroundColor Cyan

$featureCompose = Join-Path $BasePath "docker-compose-ml.yml"
@"
version: '3.8'
services:
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
  feast:
    image: feastdev/feast:0.35.0
    ports: ["6565:6565"]
    volumes: ["./feast:/feast"]
"@ | Out-File $featureCompose -Encoding utf8

$featureDef = Join-Path $BasePath "atlas-workspace\platform\configs\features.yaml"
@"
entities:
- name: tenant
  join_keys: [tenant_id]
feature_views:
- name: voucher_stats
  entities: [tenant]
  features:
    - name: vouchers_24h_count
    dtype: INT64
    - name: avg_amount_7d
    dtype: FLOAT
  source: kafka://db.vouchers
"@ | Out-File $featureDef -Encoding utf8

Write-Host "PS67 Done: Run 'feast apply' in atlas-workspace/platform/configs" -ForegroundColor Green
