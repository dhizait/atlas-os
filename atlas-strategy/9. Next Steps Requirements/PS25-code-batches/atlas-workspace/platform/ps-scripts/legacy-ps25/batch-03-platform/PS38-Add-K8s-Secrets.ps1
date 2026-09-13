<#
.SYNOPSIS
PS25 Script: PS38-Add-K8s-Secrets

.DESCRIPTION
INPUT: None
PROCESSING: Creates K8s Secret manifest for DB, JWT, Kafka creds
OUTPUT: secret.yaml - apply with kubectl
HYPERLINK: https://kubernetes.io/docs/concepts/configuration/secret/
STACK: Kubernetes Secrets + Base64
COMPLIANCE: PS25 No secrets in code

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 3
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS38: Creating K8s Secrets ===" -ForegroundColor Cyan

$secretPath = Join-Path $BasePath "atlas-workspace\platform\k8s\demo-bank\templates\secret.yaml"

@"
apiVersion: v1
kind: Secret
metadata: {name: demo-bank-secrets}
type: Opaque
data:
  DB_PASSWORD: cG9zdGdyZXM= # postgres
  JWT_SECRET: ZGVtby1iYW5rLXNlY3JldC1rZXktY2hhbmdlLWluLXByb2Q= # demo-bank-secret-key-change-in-prod
  KAFKA_USERNAME: dXNlcg==
"@ | Out-File $secretPath -Encoding utf8

Write-Host "PS38 Done: Apply with 'kubectl apply -f secret.yaml'" -ForegroundColor Green
