<#
.SYNOPSIS
PS25 Script: PS51-Add-Tenant-Switcher-RBAC

.DESCRIPTION
INPUT: frontend/src
PROCESSING: Adds TenantContext React + Role-based route guards
OUTPUT: User can switch tenant. UI hides actions by role
HYPERLINK: https://react.dev
STACK: React 18 + Vite + TypeScript + TanStack Query
COMPLIANCE: PS25 Multi-Tenancy enforced in FE

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS51: Adding Tenant Switcher + RBAC ===" -ForegroundColor Cyan

$tenantCtx = Join-Path $BasePath "frontend\src\context\TenantContext.tsx"
@"
import { createContext, useContext, useState } from 'react';
interface TenantContextType { tenantId: string; setTenantId: (id: string) => void; role: string; }
export const TenantContext = createContext<TenantContextType>({tenantId: '', setTenantId: () => {}, role: 'VIEWER'});
export const useTenant = () => useContext(TenantContext);
export const TenantProvider = ({children}: {children: React.ReactNode}) => {
  const [tenantId, setTenantId] = useState(localStorage.getItem('tenant_id') || '');
  const [role] = useState(localStorage.getItem('role') || 'VIEWER');
  return <TenantContext.Provider value={{tenantId, setTenantId, role}}>{children}</TenantContext.Provider>
}
"@ | Out-File $tenantCtx -Encoding utf8

$guard = Join-Path $BasePath "frontend\src\components\RequireRole.tsx"
@"
import { useTenant } from '../context/TenantContext';
export const RequireRole = ({role, children}: {role: string[], children: React.ReactNode}) => {
  const {role: userRole} = useTenant();
  return role.includes(userRole)? <>{children}</> : <div>Access Denied</div>
}
"@ | Out-File $guard -Encoding utf8

Write-Host "PS51 Done: Wrap App with TenantProvider. Use RequireRole for buttons" -ForegroundColor Green
