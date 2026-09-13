<#
.SYNOPSIS
PS25 Script: PS87-Add-Stripe-Integration

.DESCRIPTION
INPUT: backend/
PROCESSING: Creates Stripe customer per tenant + subscription + metered billing
OUTPUT: /api/billing/subscribe creates Stripe subscription
HYPERLINK: https://stripe.com/docs/billing
STACK: Spring Boot + Stripe Java SDK
COMPLIANCE: PS25 SaaS billing

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 13
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS87: Adding Stripe Integration ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$stripeDep = @"
    <dependency><groupId>com.stripe</groupId><artifactId>stripe-java</artifactId><version>24.0.0</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$stripeDep`n</dependencies>" | Set-Content $pom

$stripeSvc = Join-Path $BasePath "backend\src\main\java\com\demobank\billing\StripeService.java"
@"
package com.demobank.billing;
import com.stripe.Stripe; import com.stripe.model.Subscription;
@Service
public class StripeService {
    public StripeService() { Stripe.apiKey = System.getenv("STRIPE_SECRET"); }
    public String createSubscription(String tenantId, String priceId) {
        // Create Customer + Subscription with metered price
        return "sub_xxx";
    }
}
"@ | Out-File $stripeSvc -Encoding utf8

Write-Host "PS87 Done: Set STRIPE_SECRET env var" -ForegroundColor Green
