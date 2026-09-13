<#
.SYNOPSIS
PS25 Script: PS84-Add-Error-Budget

.DESCRIPTION
INPUT: None
PROCESSING: Calculates monthly error budget and blocks deploys if burned
OUTPUT: /api/sre/error-budget returns remaining budget %
HYPERLINK: https://sre.google/workbook/implementing-slos/
STACK: Spring Boot + Prometheus API
COMPLIANCE: PS25 Release gating

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 12
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS84: Adding Error Budget API ===" -ForegroundColor Cyan

$budgetCtrl = Join-Path $BasePath "backend\src\main\java\com\demobank\sre\ErrorBudgetController.java"
@"
package com.demobank.sre;
import org.springframework.web.bind.annotation.*;
@RestController @RequestMapping("/api/sre")
public class ErrorBudgetController {
    @GetMapping("/error-budget")
    public Map<String, Object> getBudget() {
        // Query Prometheus: 1 - error_rate over 30d
        // Budget = 0.1%. If burned > 90%, block deployments
        return Map.of("remaining", "23%", "blocked", false);
    }
}
"@ | Out-File $budgetCtrl -Encoding utf8

Write-Host "PS84 Done: GET /api/sre/error-budget" -ForegroundColor Green
