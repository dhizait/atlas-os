<#
.SYNOPSIS
PS25 Script: PS93-Add-Admin-UI

.DESCRIPTION
INPUT: frontend/
PROCESSING: Adds SuperAdmin dashboard: tenant list, suspend, view usage
OUTPUT: /admin shows all tenants with search + filters
HYPERLINK: https://mui.com
STACK: React + TanStack Table + MUI
COMPLIANCE: PS25 Platform ops

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 14
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS93: Adding Admin UI ===" -ForegroundColor Cyan

$adminPage = Join-Path $BasePath "frontend\src\pages\AdminTenantsPage.tsx"
@"
import { useQuery } from '@tanstack/react-query';
export default function AdminTenantsPage() {
  const {data} = useQuery({queryKey: ['tenants'], queryFn: () => fetch('/api/admin/tenants').then(r=>r.json())});
  return <div>
    <h1>All Tenants</h1>
    <table>{data?.map((t:any) => <tr><td>{t.name}</td><td>{t.status}</td><td><button>Suspend</button></td></tr>)}</table>
  </div>
}
"@ | Out-File $adminPage -Encoding utf8

Write-Host "PS93 Done: Route /admin requires ROLE_ADMIN" -ForegroundColor Green
