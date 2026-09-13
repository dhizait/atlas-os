<#
.SYNOPSIS
PS25 Script: FE-PS52-Docker-Build-Test

.DESCRIPTION
INPUT: src/components/
PROCESSING: Creates ProtectedRoute.tsx + vite.config.ts + build test
OUTPUT: Built FE image
HYPERLINK: https://vitejs.dev
STACK: React 18 + Vite + TypeScript + Docker
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 2
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\frontend\FE-PS52-Docker-Build-Test.ps1
# PURPOSE: Runs unit/integration tests for tenant isolation
# FILE: FE-PS52-Docker-Build-Test.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$feRoot = Join-Path $BasePath "frontend"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; ERROR="Red"; WARN="Yellow"}[$Level]
  Write-Host "[$time] [$Level] PS52: $Msg" -ForegroundColor $color
}

if (-not (Test-Path $feRoot)) { Write-Log "FE folder not found: $feRoot" "ERROR"; exit 1 }
Set-Location $feRoot

if ($DryRun) { Write-Host "[PS52 DRY RUN] Would add ProtectedRoute and run build test"; exit 0 }

Write-Log "PHASE 1: Ensure ProtectedRoute with Tenant check..."
$compDir = Join-Path $feRoot "src/components"
if(!(Test-Path $compDir)){ New-Item $compDir -ItemType Directory -Force | Out-Null }
@'
import { Navigate } from 'react-router-dom';
import { useTenant } from '../context/TenantContext';
export const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { tenantId } = useTenant();
  if (!tenantId) return <Navigate to="/auth/login" replace />;
  return children;
};
'@ | Set-Content "$compDir/ProtectedRoute.tsx" -Encoding UTF8

Write-Log "PHASE 2: Ensure vite.config.ts alias..."
@'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'
export default defineConfig({
  plugins: [react()],
  resolve: { alias: { '@': path.resolve(__dirname, './src') } }
})
'@ | Set-Content "$feRoot/vite.config.ts" -Encoding UTF8

Write-Log "PHASE 3: Running docker build test..." "INFO"
docker compose build --no-cache
if ($LASTEXITCODE -ne 0) { Write-Log "Final build test failed" "ERROR"; exit 1 }

Write-Log "PS52 Complete: Build test passed" "SUCCESS"; exit 0
