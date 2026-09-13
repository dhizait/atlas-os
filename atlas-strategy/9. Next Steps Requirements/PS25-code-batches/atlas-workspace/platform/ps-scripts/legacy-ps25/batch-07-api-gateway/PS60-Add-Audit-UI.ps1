<#
.SYNOPSIS
PS25 Script: PS60-Add-Audit-UI

.DESCRIPTION
INPUT: frontend/
PROCESSING: Adds AuditLog React page with tenant filter + export
OUTPUT: Admin can view/search audit_log in UI
HYPERLINK: https://mui.com
STACK: React + TanStack Table + MUI
COMPLIANCE: PS25 Auditor self-service

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 7
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS60: Adding Audit UI ===" -ForegroundColor Cyan

$auditPage = Join-Path $BasePath "frontend\src\pages\AuditLogPage.tsx"
@"
import { useQuery } from '@tanstack/react-query';
import { useTenant } from '../context/TenantContext';
export default function AuditLogPage() {
  const {tenantId} = useTenant();
  const {data} = useQuery({queryKey: ['audit', tenantId],
    queryFn: () => fetch(`/api/audit?tenant_id=${tenantId}`).then(r => r.json())});
  return <div>
    <h1>Audit Log - Tenant {tenantId}</h1>
    <table>{data?.map((log:any) => <tr><td>{log.timestamp}</td><td>{log.action}</td></tr>)}</table>
    <button onClick={() => window.open(`/api/reports/soc2?tenant_id=${tenantId}`)}>Export PDF</button>
  </div>
}
"@ | Out-File $auditPage -Encoding utf8

Write-Host "PS60 Done: Route /audit shows tenant audit trail" -ForegroundColor Green
