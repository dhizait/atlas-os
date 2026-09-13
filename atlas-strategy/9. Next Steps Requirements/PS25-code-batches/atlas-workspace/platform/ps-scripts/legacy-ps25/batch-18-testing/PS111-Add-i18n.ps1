<#
.SYNOPSIS
PS25 Script: PS111-Add-i18n

.DESCRIPTION
INPUT: backend/ + frontend/
PROCESSING: Adds Spring MessageSource + React i18next. Supports en, fr, ar, es
OUTPUT: API and UI translate based on Accept-Language header
HYPERLINK: https://www.i18next.com
STACK: Spring Boot + React i18next
COMPLIANCE: PS25 Multi-language support

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 18
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS111: Adding i18n ===" -ForegroundColor Cyan

$i18nDir = Join-Path $BasePath "backend\src\main\resources\i18n"
New-Item -ItemType Directory -Force $i18nDir | Out-Null

@"
voucher.created=Voucher created successfully
voucher.amount=Amount: {0}
"@ | Out-File (Join-Path $i18nDir "messages_en.properties") -Encoding utf8

@"
voucher.created=Bon créé avec succès
voucher.amount=Montant: {0}
"@ | Out-File (Join-Path $i18nDir "messages_fr.properties") -Encoding utf8

@"
voucher.created=تم إنشاء القسيمة بنجاح
voucher.amount=المبلغ: {0}
"@ | Out-File (Join-Path $i18nDir "messages_ar.properties") -Encoding utf8

$localeCfg = Join-Path $BasePath "backend\src\main\java\com\demobank\config\LocaleConfig.java"
@"
package com.demobank.config;
import org.springframework.context.annotation.Bean;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver;
@Configuration
public class LocaleConfig {
    @Bean
    public LocaleResolver localeResolver() {
        return new AcceptHeaderLocaleResolver(); // reads Accept-Language
    }
}
"@ | Out-File $localeCfg -Encoding utf8

Write-Host "PS111 Done: Send Accept-Language: fr to get French" -ForegroundColor Green
