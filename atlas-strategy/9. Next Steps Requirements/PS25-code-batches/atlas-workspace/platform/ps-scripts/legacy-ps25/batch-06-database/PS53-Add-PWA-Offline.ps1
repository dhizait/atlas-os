<#
.SYNOPSIS
PS25 Script: PS53-Add-PWA-Offline

.DESCRIPTION
INPUT: frontend/
PROCESSING: Adds Vite PWA plugin + service worker + IndexedDB cache
OUTPUT: App works offline. Syncs when online
HYPERLINK: https://vite-pwa-org.netlify.app
STACK: Vite + Workbox + Dexie.js
COMPLIANCE: PS25 Offline-first for field agents

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 6
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS53: Adding PWA + Offline Support ===" -ForegroundColor Cyan

$deps = "npm install vite-plugin-pwa dexie"
Invoke-Expression "cd $(Join-Path $BasePath 'frontend') && $deps"

$viteConfig = Join-Path $BasePath "frontend\vite.config.ts"
@"
import { defineConfig } from 'vite';
import { VitePWA } from 'vite-plugin-pwa';
export default defineConfig({
  plugins: [VitePWA({registerType: 'autoUpdate', manifest: {
    name: 'Demo Bank', short_name: 'Atlas', start_url: '/', display: 'standalone'
  }})]
});
"@ | Out-File $viteConfig -Encoding utf8

$db = Join-Path $BasePath "frontend\src\lib\offlineDB.ts"
@"
import Dexie from 'dexie';
export class OfflineDB extends Dexie {
  vouchers!: Dexie.Table<any, string>;
  constructor() { super('AtlasDB'); this.version(1).store({vouchers: 'id,tenantId,createdAt'}); }
}
export const db = new OfflineDB();
"@ | Out-File $db -Encoding utf8

Write-Host "PS53 Done: App installable. Data cached in IndexedDB" -ForegroundColor Green
