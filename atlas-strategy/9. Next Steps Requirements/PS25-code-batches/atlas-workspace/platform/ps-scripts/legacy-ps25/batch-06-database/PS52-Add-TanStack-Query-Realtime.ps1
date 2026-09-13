<#
.SYNOPSIS
PS25 Script: PS52-Add-TanStack-Query-Realtime

.DESCRIPTION
INPUT: frontend/src
PROCESSING: Adds TanStack Query + WebSocket for live voucher updates
OUTPUT: Voucher list auto-refreshes on Kafka event
HYPERLINK: https://tanstack.com/query
STACK: React Query + WebSocket + Spring WebSocket
COMPLIANCE: PS25 Real-time UX per tenant

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS52: Adding TanStack Query + Realtime ===" -ForegroundColor Cyan

$deps = "npm install @tanstack/react-query"
Invoke-Expression "cd $(Join-Path $BasePath 'frontend') && $deps"

$queryClient = Join-Path $BasePath "frontend\src\lib\queryClient.ts"
@"
import { QueryClient } from '@tanstack/react-query';
export const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 1000 * 30, refetchOnWindowFocus: false } }
});
"@ | Out-File $queryClient -Encoding utf8

$wsHook = Join-Path $BasePath "frontend\src\hooks\useVoucherSocket.ts"
@"
import { useEffect } from 'react';
import { queryClient } from '../lib/queryClient';
import { useTenant } from '../context/TenantContext';
export const useVoucherSocket = () => {
  const {tenantId} = useTenant();
  useEffect(() => {
    const ws = new WebSocket(`ws://localhost:8080/ws/vouchers?tenant_id=${tenantId}`);
    ws.onmessage = () => queryClient.invalidateQueries({queryKey: ['vouchers', tenantId]});
    return () => ws.close();
  }, [tenantId]);
}
"@ | Out-File $wsHook -Encoding utf8

Write-Host "PS52 Done: Call useVoucherSocket() in VoucherList component" -ForegroundColor Green
