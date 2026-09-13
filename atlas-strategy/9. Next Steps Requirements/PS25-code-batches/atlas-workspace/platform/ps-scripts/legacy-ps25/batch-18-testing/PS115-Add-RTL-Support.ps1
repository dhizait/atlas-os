<#
.SYNOPSIS
PS25 Script: PS115-Add-RTL-Support

.DESCRIPTION
INPUT: frontend/
PROCESSING: Adds RTL support for Arabic. Flips layout based on locale
OUTPUT: dir="rtl" when locale=ar
HYPERLINK: https://mui.com/material-ui/guides/right-to-left/
STACK: React + MUI + i18next
COMPLIANCE: PS25 Arabic support

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 18
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS115: Adding RTL Support ===" -ForegroundColor Cyan

$rtlWrapper = Join-Path $BasePath "frontend\src\components\RtlWrapper.tsx"
@"
import { ThemeProvider, createTheme } from '@mui/material';
import rtlPlugin from 'stylis-plugin-rtl';
import { CacheProvider } from '@emotion/react';
import createCache from '@emotion/cache';

export default function RtlWrapper({children, locale}) {
  const isRtl = locale === 'ar';
  const theme = createTheme({direction: isRtl? 'rtl' : 'ltr'});
  const cacheRtl = createCache({key: 'muirtl', stylisPlugins: [rtlPlugin]});

  return <CacheProvider value={isRtl? cacheRtl : undefined}>
    <ThemeProvider theme={theme}><div dir={isRtl? 'rtl' : 'ltr'}>{children}</div></ThemeProvider>
  </CacheProvider>
}
"@ | Out-File $rtlWrapper -Encoding utf8

Write-Host "PS115 Done: Wrap App with <RtlWrapper locale={i18n.language}>" -ForegroundColor Green
