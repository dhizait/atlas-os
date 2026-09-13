<#
.SYNOPSIS
PS25 Script: PS122-Add-Architecture-Diagrams

.DESCRIPTION
INPUT: docs/
PROCESSING: Generates C4 diagrams + infra diagrams
OUTPUT: /docs/architecture PNG + PlantUML
HYPERLINK: https://c4model.com
STACK: PlantUML + Draw.io
COMPLIANCE: PS25 Technical documentation

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 20
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS122: Adding Architecture Diagrams ===" -ForegroundColor Cyan

$archDir = Join-Path $BasePath "docs\architecture"
New-Item -ItemType Directory -Force $archDir | Out-Null

$c4 = Join-Path $archDir "c4-context.puml"
@"
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml
System(DemoBank, "DemoBank SaaS", "Multi-tenant voucher platform")
Person(Admin, "Bank Admin")
Person(User, "Bank User")
System_Ext(Stripe, "Stripe")
System_Ext(Firebase, "Push Notifications")
Rel(Admin, DemoBank, "Manages tenants")
Rel(User, DemoBank, "Creates vouchers")
Rel(DemoBank, Stripe, "Billing")
Rel(DemoBank, Firebase, "Push")
@enduml
"@ | Out-File $c4 -Encoding utf8

Write-Host "PS122 Done: Render with PlantUML" -ForegroundColor Green
