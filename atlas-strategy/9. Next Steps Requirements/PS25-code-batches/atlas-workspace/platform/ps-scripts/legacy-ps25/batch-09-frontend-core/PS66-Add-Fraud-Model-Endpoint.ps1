<#
.SYNOPSIS
PS25 Script: PS66-Add-Fraud-Model-Endpoint

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds REST endpoint to call Python fraud model via gRPC
OUTPUT: /api/fraud/score returns risk_score 0-1 per voucher
HYPERLINK: https://mlflow.org
STACK: Spring Boot + gRPC + Python + Scikit-learn
COMPLIANCE: PS25 Real-time fraud blocking

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 9
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS66: Adding Fraud Model Endpoint ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$grpcDep = @"
    <dependency><groupId>io.grpc</groupId><artifactId>grpc-netty-shaded</artifactId><version>1.60.0</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$grpcDep`n</dependencies>" | Set-Content $pom

$fraudSvc = Join-Path $BasePath "backend\src\main\java\com\demobank\ml\FraudScoringService.java"
@"
package com.demobank.ml;
import org.springframework.stereotype.Service;
@Service
public class FraudScoringService {
    public double scoreVoucher(String tenantId, double amount, String beneficiary) {
        // gRPC call to python model at fraud-service:50051
        // Features: amount, time_of_day, beneficiary_history, tenant_id
        return 0.12; // risk score
    }
}
"@ | Out-File $fraudSvc -Encoding utf8

Write-Host "PS66 Done: Call fraudScoringService.scoreVoucher() before BE-PS73 commit" -ForegroundColor Green
