<#
.SYNOPSIS
PS25 Script: PS73-Add-CDN-Asset-Cache

.DESCRIPTION
INPUT: frontend/
PROCESSING: Configures Vite for CDN + cache busting + tenant assets
OUTPUT: Static assets served from cdn.demo-bank.com
HYPERLINK: https://vitejs.dev
STACK: Vite + Cloudflare CDN
COMPLIANCE: PS25 <2s FE load time

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 10
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS73: Adding CDN Asset Cache ===" -ForegroundColor Cyan

$viteConfig = Join-Path $BasePath "frontend\vite.config.ts"
@"
import { defineConfig } from 'vite';
export default defineConfig({
  base: 'https://cdn.demo-bank.com/',
  build: {
    assetsDir: 'assets',
    rollupOptions: { output: { assetFileNames: 'assets/[name].[hash].[ext]' } }
  }
});
"@ | Out-File $viteConfig -Encoding utf8

Write-Host "PS73 Done: Build assets with 'npm run build'. Upload to CDN" -ForegroundColor Green
