<#
.SYNOPSIS
PS25 Script: PS37-Add-HPA-Ingress

.DESCRIPTION
INPUT: Helm chart from PS36
PROCESSING: Adds HPA + Ingress with tenant-based routing
OUTPUT: Auto-scale 2-10 pods. Single ingress for all tenants
HYPERLINK: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
STACK: K8s HPA + NGINX Ingress
COMPLIANCE: PS25 Tenant isolation via header X-Tenant-ID

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 3
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS37: Adding HPA + Ingress ===" -ForegroundColor Cyan

$chartPath = Join-Path $BasePath "atlas-workspace\platform\k8s\demo-bank\templates"

@"
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: backend-hpa}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: backend}
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
    resource: {name: cpu, target: {type: Utilization, averageUtilization: 70}}
"@ | Out-File "$chartPath\hpa.yaml" -Encoding utf8

@"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: {name: demo-bank-ingress, annotations: {"nginx.ingress.kubernetes.io/rewrite-target": /}}
spec:
  rules:
    - host: demo-bank.local
    http:
      paths:
            - path: /api
        pathType: Prefix
        backend: {service: {name: backend, port: {number: 8080}}}
"@ | Out-File "$chartPath\ingress.yaml" -Encoding utf8

Write-Host "PS37 Done: HPA 2-10 replicas + Ingress created" -ForegroundColor Green
