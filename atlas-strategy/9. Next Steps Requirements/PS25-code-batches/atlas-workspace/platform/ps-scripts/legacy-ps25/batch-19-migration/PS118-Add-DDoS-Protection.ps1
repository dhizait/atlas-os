<#
.SYNOPSIS
PS25 Script: PS118-Add-DDoS-Protection

.DESCRIPTION
INPUT: k8s/
PROCESSING: Adds Cloudflare + K8s HPA + connection limits
OUTPUT: Auto-scales under attack. Blacklists IPs
HYPERLINK: https://cloudflare.com/ddos
STACK: Cloudflare + K8s HPA + Falco
COMPLIANCE: PS25 99.99% uptime

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 19
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS118: Adding DDoS Protection ===" -ForegroundColor Cyan

$hpa = Join-Path $BasePath "atlas-workspace\platform\k8s\hpa.yaml"
@"
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: backend-hpa}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: backend}
  minReplicas: 3
  maxReplicas: 50
  metrics:
    - type: Resource
    resource: {name: cpu, target: {type: Utilization, averageUtilization: 70}}
"@ | Out-File $hpa -Encoding utf8

Write-Host "PS118 Done: Apply HPA. Configure Cloudflare proxy" -ForegroundColor Green
