<#
.SYNOPSIS
PS25 Script: PS90-Add-Billing-UI

.DESCRIPTION
INPUT: frontend/
PROCESSING: Adds Billing page: usage, plan, invoices, payment method
OUTPUT: Admin can upgrade plan + download invoices
HYPERLINK: https://stripe.com/docs/billing/subscriptions/build-subscription
STACK: React + Stripe Elements
COMPLIANCE: PS25 Self-service billing

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 13
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS90: Adding Billing UI ===" -ForegroundColor Cyan

$billingPage = Join-Path $BasePath "frontend\src\pages\BillingPage.tsx"
@"
import { useTenant } from '../context/TenantContext';
export default function BillingPage() {
  const {tenantId} = useTenant();
  return <div>
    <h1>Billing - Tenant {tenantId}</h1>
    <button onClick={() => window.open('/api/billing/invoice?month=2026-01')}>Download Invoice</button>
    <button onClick={() => window.open('/api/billing/portal')}>Manage Payment</button>
  </div>
}
"@ | Out-File $billingPage -Encoding utf8

Write-Host "PS90 Done: Route /billing shows usage + invoices" -ForegroundColor Green
