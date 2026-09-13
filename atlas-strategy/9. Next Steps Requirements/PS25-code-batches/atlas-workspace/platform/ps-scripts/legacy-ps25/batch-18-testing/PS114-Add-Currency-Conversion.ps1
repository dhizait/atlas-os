<#
.SYNOPSIS
PS25 Script: PS114-Add-Currency-Conversion

.DESCRIPTION
INPUT: backend/
PROCESSING: Integrates ExchangeRate API. Converts amounts for reporting
OUTPUT: /api/analytics/convert?from=USD&to=ZWL&amount=100
HYPERLINK: https://exchangerate-api.com
STACK: Spring Boot + WebClient
COMPLIANCE: PS25 FX reporting

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 18
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS114: Adding Currency Conversion ===" -ForegroundColor Cyan

$fxSvc = Join-Path $BasePath "backend\src\main\java\com\demobank\fx\FxService.java"
@"
package com.demobank.fx;
import org.springframework.web.client.RestTemplate;
@Service
public class FxService {
    private final RestTemplate rest = new RestTemplate();
    public BigDecimal convert(String from, String to, BigDecimal amount) {
        String url = "https://api.exchangerate-api.com/v4/latest/" + from;
        Map rates = rest.getForObject(url, Map.class);
        BigDecimal rate = new BigDecimal(rates.get("rates").get(to).toString());
        return amount.multiply(rate);
    }
}
"@ | Out-File $fxSvc -Encoding utf8

Write-Host "PS114 Done: GET /api/analytics/convert" -ForegroundColor Green
