<#
.SYNOPSIS
PS25 Script: PS55-Add-FE-E2E-Tests

.DESCRIPTION
INPUT: frontend/
PROCESSING: Adds Playwright tests for tenant login + voucher flow
OUTPUT: E2E test suite runs in CI
HYPERLINK: https://playwright.dev
STACK: Playwright + TypeScript
COMPLIANCE: PS25 Automated FE regression

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS55: Adding Playwright E2E Tests ===" -ForegroundColor Cyan

$pw = "npx playwright install && npx playwright test --init"
Invoke-Expression "cd $(Join-Path $BasePath 'frontend') && $pw"

$test = Join-Path $BasePath "frontend\tests\voucher-flow.spec.ts"
@"
import { test, expect } from '@playwright/test';
test('tenant can create voucher', async ({ page }) => {
  await page.goto('/');
  await page.fill('[name=tenant_id]', 'TENANT001');
  await page.click('text=Login');
  await page.click('text=New Voucher');
  await page.fill('[name=amount]', '1000');
  await page.click('text=Submit');
  await expect(page.locator('text=Voucher Created')).toBeVisible();
});
"@ | Out-File $test -Encoding utf8

Write-Host "PS55 Done: Run 'npx playwright test'" -ForegroundColor Green
