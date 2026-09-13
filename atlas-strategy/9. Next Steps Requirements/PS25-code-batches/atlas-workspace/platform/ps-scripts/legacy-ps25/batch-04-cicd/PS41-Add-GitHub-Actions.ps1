<#
.SYNOPSIS
PS25 Script: PS41-Add-GitHub-Actions

.DESCRIPTION
INPUT: backend/, frontend/
PROCESSING: Creates GitHub Actions workflows for build, test, docker push
OUTPUT:.github/workflows/ci-cd.yml - runs on every push to main
HYPERLINK: https://github.com/features/actions
STACK: GitHub Actions + Maven + Node + Docker
COMPLIANCE: PS25 Automated release pipeline

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS41: Adding GitHub Actions CI/CD ===" -ForegroundColor Cyan

$workflowDir = Join-Path $BasePath ".github\workflows"
New-Item -ItemType Directory -Force $workflowDir | Out-Null

$workflow = Join-Path $workflowDir "ci-cd.yml"
@"
name: Atlas CI-CD
on: {push: {branches: [main]}, pull_request: {branches: [main]}}
jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Set up JDK 21
      uses: actions/setup-java@v4
      with: {java-version: '21', distribution: 'temurin'}
    - name: Backend Build + Test
      run: cd backend && mvn clean verify
    - name: Frontend Build
      run: cd frontend && npm ci && npm run build
    - name: Docker Build & Push
      run: |
        docker build -t demobank/backend:${{ github.sha }} backend
        docker push demobank/backend:${{ github.sha }}
"@ | Out-File $workflow -Encoding utf8

Write-Host "PS41 Done: Workflow at.github/workflows/ci-cd.yml" -ForegroundColor Green
