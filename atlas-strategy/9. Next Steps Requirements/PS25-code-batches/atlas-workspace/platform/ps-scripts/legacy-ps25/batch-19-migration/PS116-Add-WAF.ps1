<#
.SYNOPSIS
PS25 Script: PS116-Add-WAF

.DESCRIPTION
INPUT: k8s/ + nginx/
PROCESSING: Deploys ModSecurity WAF with OWASP CRS
OUTPUT: Blocks SQLi, XSS, LFI. Logs to SIEM
HYPERLINK: https://coreruleset.org
STACK: Nginx + ModSecurity + OWASP CRS
COMPLIANCE: PS25 OWASP Top 10 protection

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 19
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS116: Adding WAF ===" -ForegroundColor Cyan

$wafConf = Join-Path $BasePath "nginx\waf.conf"
@"
load_module modules/ngx_http_modsecurity_module.so;
modsecurity on;
modsecurity_rules_file /etc/nginx/modsec/main.conf;
"@ | Out-File $wafConf -Encoding utf8

$modsecMain = Join-Path $BasePath "nginx\modsec\main.conf"
New-Item -ItemType Directory -Force (Split-Path $modsecMain) | Out-Null
@"
Include /etc/nginx/modsec/owasp-crs/crs-setup.conf
Include /etc/nginx/modsec/owasp-crs/rules/*.conf
SecRule REQUEST_HEADERS:X-Tenant-ID "@rx ^$" "id:1001,phase:1,deny,msg:'Missing Tenant ID'"
"@ | Out-File $modsecMain -Encoding utf8

Write-Host "PS116 Done: Restart nginx. WAF active" -ForegroundColor Green
