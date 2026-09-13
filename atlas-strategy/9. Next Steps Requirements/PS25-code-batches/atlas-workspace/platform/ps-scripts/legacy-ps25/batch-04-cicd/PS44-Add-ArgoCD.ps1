<#
.SYNOPSIS
PS25 Script: PS44-Add-ArgoCD

.DESCRIPTION
INPUT: Helm chart from PS36
PROCESSING: Creates ArgoCD Application manifest for GitOps deployment
OUTPUT: Auto-sync K8s from git repo
HYPERLINK: https://argo-cd.readthedocs.io
STACK: ArgoCD + Helm + K8s
COMPLIANCE: PS25 GitOps - everything as code

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS44: Adding ArgoCD Application ===" -ForegroundColor Cyan

$argoPath = Join-Path $BasePath "atlas-workspace\platform\k8s\argocd"
New-Item -ItemType Directory -Force $argoPath | Out-Null

$app = Join-Path $argoPath "demo-bank-app.yaml"
@"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata: {name: demo-bank}
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/demo-bank
    targetRevision: HEAD
    path: atlas-workspace/platform/k8s/demo-bank
  destination: {server: https://kubernetes.default.svc, namespace: demo-bank}
  syncPolicy: {automated: {prune: true, selfHeal: true}}
"@ | Out-File $app -Encoding utf8

Write-Host "PS44 Done: Apply with 'kubectl apply -f argocd/demo-bank-app.yaml'" -ForegroundColor Green
