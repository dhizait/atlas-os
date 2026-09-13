<#
.SYNOPSIS
PS25 Script: PS110-Add-Deep-Linking

.DESCRIPTION
INPUT: mobile/ + backend/
PROCESSING: Adds deep links: demobank://voucher/{id}
OUTPUT: Mobile opens directly to voucher detail
HYPERLINK: https://reactnavigation.org/docs/deep-linking
STACK: React Native + Spring Redirect
COMPLIANCE: PS25 UX

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 17
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS110: Adding Deep Linking ===" -ForegroundColor Cyan

$linkConfig = Join-Path $BasePath "mobile\linking.ts"
@"
export const linking = {
  prefixes: ['demobank://', 'https://app.demo-bank.com'],
  config: {
    screens: {
      VoucherDetail: 'voucher/:id'
    }
  }
}
"@ | Out-File $linkConfig -Encoding utf8

$redirectCtrl = Join-Path $BasePath "backend\src\main\java\com\demobank\web\RedirectController.java"
@"
package com.demobank.web;
@Controller
public class RedirectController {
    @GetMapping("/voucher/{id}")
    public String redirect(@PathVariable String id) {
        return "redirect:demobank://voucher/" + id;
    }
}
"@ | Out-File $redirectCtrl -Encoding utf8

Write-Host "PS110 Done: https://api.demo-bank.com/voucher/123 opens app" -ForegroundColor Green
