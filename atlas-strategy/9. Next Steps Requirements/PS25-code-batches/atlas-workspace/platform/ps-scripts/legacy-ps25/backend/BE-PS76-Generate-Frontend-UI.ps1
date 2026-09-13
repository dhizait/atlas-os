<#
.SYNOPSIS
PS25 Script: BE-PS76-Generate-Frontend-UI

.DESCRIPTION
INPUT: frontend/
PROCESSING: Creates React package.json + App.jsx with axios header
OUTPUT: package.json, src/App.jsx
HYPERLINK: https://vitejs.dev
STACK: React 18 + Vite + TypeScript + Docker
COMPLIANCE: PS25 Multi-Tenancy via X-Tenant-ID

.NOTES
Generated: 2026-08-05
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

# FilePath: C:\Atlas\releases\R01\demo-bank\atlas-workspace\platform\ps-scripts\backend\BE-PS76-Generate-Frontend-UI.ps1
# PURPOSE: Performs core PS25 automation task
# FILE: BE-PS76-Generate-Frontend-UI.ps1
# AUDIT: 2026-08-02

param(
  [Parameter(Mandatory=$true)]
  [string]$BasePath,
  [string]$Framework = "react",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$FeRoot = Join-Path $BasePath "frontend"

function Write-Log {
  param([string]$Msg, [string]$Level="INFO")
  $time = Get-Date -Format "HH:mm:ss"
  $color = @{INFO="Cyan"; SUCCESS="Green"; WARN="Yellow"; ERROR="Red"}[$Level]
  Write-Host "[$time] [$Level] PS76: $Msg" -ForegroundColor $color
}

Write-Host "PS76: Generate Frontend UI" -ForegroundColor Magenta
if ($DryRun) { Write-Host "[PS76 DRY RUN] Would create package.json + src/App.jsx in $FeRoot"; exit 0 }

New-Item -ItemType Directory -Path $FeRoot -Force | Out-Null

$pkgPath = Join-Path $FeRoot "package.json"
@"
{
  "name": "demo-bank-fe",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.4.0"
  }
}
"@ | Set-Content $pkgPath -Encoding UTF8
Write-Log "Created: package.json" "SUCCESS"

$srcDir = Join-Path $FeRoot "src"
New-Item -ItemType Directory -Path $srcDir -Force | Out-Null

$appPath = Join-Path $srcDir "App.jsx"
@'
import { useState, useEffect } from 'react'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8081'

function App() {
  const [tenant, setTenant] = useState('TENANT001')
  const [vouchers, setVouchers] = useState([])

  // PS25: Attach X-Tenant-ID to all requests
  useEffect(() => {
    axios.defaults.headers.common['X-Tenant-ID'] = tenant
    axios.defaults.baseURL = API_URL

    axios.get('/api/v1/vouchers')
 .then(res => setVouchers(res.data))
 .catch(err => console.error('Tenant header missing:', err))
  }, [tenant])

  return (
    <div style={{padding: '20px'}}>
      <h1>Demo Bank Platform</h1>
      <input
        value={tenant}
        onChange={e => setTenant(e.target.value)}
        placeholder="Enter Tenant ID"
      />
      <p>Current Tenant: {tenant}</p>
      <p>PS25 Multi-tenancy enabled</p>
      <ul>
        {vouchers.map(v => <li key={v.id}>{v.code || v.id} - {v.amount}</li>)}
      </ul>
    </div>
  )
}

export default App
'@ | Set-Content $appPath -Encoding UTF8
Write-Log "Created: src/App.jsx" "SUCCESS"

Write-Log "PS76 Complete! Run 'npm install && npm run dev' in $FeRoot" "SUCCESS"; exit 0
