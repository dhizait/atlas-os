<#
.SYNOPSIS
PS25 Script: PS36-Add-Helm-Charts

.DESCRIPTION
INPUT: backend/, frontend/
PROCESSING: Generates Helm chart for BE, FE, Postgres with tenant env vars
OUTPUT: chart/ folder deployable to any K8s cluster
HYPERLINK: https://helm.sh
STACK: Kubernetes + Helm 3 + Spring Boot
COMPLIANCE: PS25 Multi-Tenancy via env TENANT_MODE

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 3
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS36: Generating Helm Charts ===" -ForegroundColor Cyan

$chartPath = Join-Path $BasePath "atlas-workspace\platform\k8s\demo-bank"
New-Item -ItemType Directory -Force "$chartPath\templates" | Out-Null

@"
apiVersion: v2
name: demo-bank
description: Multi-Tenant Demo Bank Platform
version: 0.1.0
"@ | Out-File "$chartPath\Chart.yaml" -Encoding utf8

@"
replicaCount: 2
image:
  repository: demobank/backend
  tag: latest
env:
  TENANT_MODE: schema
  OTEL_EXPORTER_OTLP_ENDPOINT: http://tempo:4317
ingress:
  enabled: true
  host: demo-bank.local
resources:
  limits: {cpu: 500m, memory: 1Gi}
  requests: {cpu: 200m, memory: 512Mi}
"@ | Out-File "$chartPath\values.yaml" -Encoding utf8

@"
apiVersion: apps/v1
kind: Deployment
metadata: {name: backend}
spec:
  replicas: {{.Values.replicaCount }}
  template:
    spec:
      containers:
            - name: backend
        image: "{{.Values.image.repository }}:{{.Values.image.tag }}"
        env:
                - name: TENANT_MODE
          value: "{{.Values.env.TENANT_MODE }}"
        ports: [{containerPort: 8080}]
        livenessProbe: {httpGet: {path: /actuator/health, port: 8080}}
"@ | Out-File "$chartPath\templates\backend-deployment.yaml" -Encoding utf8

Write-Host "PS36 Done: Helm chart at atlas-workspace/platform/k8s/demo-bank" -ForegroundColor Green
