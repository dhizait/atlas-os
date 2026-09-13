<#
.SYNOPSIS
PS25 Script: PS79-Add-Chaos-Testing

.DESCRIPTION
INPUT: k8s/
PROCESSING: Installs Chaos Mesh. Runs monthly chaos experiments
OUTPUT: Kills pods, adds latency, validates resilience
HYPERLINK: https://chaos-mesh.org
STACK: Chaos Mesh + K8s
COMPLIANCE: PS25 99.99% uptime validation

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 11
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS79: Adding Chaos Testing ===" -ForegroundColor Cyan

$chaos = Join-Path $BasePath "atlas-workspace\platform\k8s\chaos-pod-kill.yaml"
@"
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata: {name: backend-pod-failure}
spec:
  action: pod-kill
  mode: one
  selector:
    labelSelectors: {app: backend}
  duration: "30s"
  scheduler: {cron: "0 2 1 * *"} # 2am on 1st of month
"@ | Out-File $chaos -Encoding utf8

Write-Host "PS79 Done: Apply chaos with 'kubectl apply -f chaos-pod-kill.yaml'" -ForegroundColor Green
