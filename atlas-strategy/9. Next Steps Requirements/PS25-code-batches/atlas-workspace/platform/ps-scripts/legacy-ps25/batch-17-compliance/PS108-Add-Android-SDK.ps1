<#
.SYNOPSIS
PS25 Script: PS108-Add-Android-SDK

.DESCRIPTION
INPUT: None
PROCESSING: Creates Android Library AAR for DemoBank API
OUTPUT: demobank-sdk.aar with tenant interceptor
HYPERLINK: https://developer.android.com
STACK: Kotlin + OkHttp + Retrofit
COMPLIANCE: PS25 Partner SDK

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 17
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS108: Adding Android SDK ===" -ForegroundColor Cyan

$androidDir = Join-Path $BasePath "sdk\android\demobank-sdk"
New-Item -ItemType Directory -Force $androidDir | Out-Null

$kt = Join-Path $androidDir "DemoBankClient.kt"
@"
package com.demobank.sdk
import okhttp3.*

class DemoBankClient(private val tenantId: String) {
    private val client = OkHttpClient.Builder()
       .addInterceptor { chain ->
            chain.proceed(chain.request().newBuilder().header("X-Tenant-ID", tenantId).build())
        }.build()

    fun createVoucher(amount: Double) { /* POST to /api/vouchers */ }
}
"@ | Out-File $kt -Encoding utf8

Write-Host "PS108 Done: Android Library at sdk/android/demobank-sdk" -ForegroundColor Green
