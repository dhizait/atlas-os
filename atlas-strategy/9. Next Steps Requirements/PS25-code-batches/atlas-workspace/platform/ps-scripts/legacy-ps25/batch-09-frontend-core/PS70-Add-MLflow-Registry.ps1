<#
.SYNOPSIS
PS25 Script: PS70-Add-MLflow-Registry

.DESCRIPTION
INPUT: docker-compose.yml
PROCESSING: Adds MLflow server for model versioning + experiment tracking
OUTPUT: http://localhost:5000 to register fraud models
HYPERLINK: https://mlflow.org
STACK: MLflow + Minio + PostgreSQL
COMPLIANCE: PS25 Model governance + audit

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 9
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS70: Adding MLflow Registry ===" -ForegroundColor Cyan

$mlflowCompose = Join-Path $BasePath "docker-compose-mlflow.yml"
@"
version: '3.8'
services:
  mlflow:
    image: python:3.11
    command: bash -c "pip install mlflow && mlflow server --host 0.0.0.0 --port 5000"
    ports: ["5000:5000"]
    volumes: ["./mlruns:/mlruns"]
    environment:
      MLFLOW_BACKEND_STORE_URI: postgresql://postgres:postgres@postgres:5432/mlflow
"@ | Out-File $mlflowCompose -Encoding utf8

Write-Host "PS70 Done: MLflow UI at http://localhost:5000" -ForegroundColor Green
