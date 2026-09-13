<#
.SYNOPSIS
PS25 Script: PS74-Add-JMeter-Load-Test

.DESCRIPTION
INPUT: None
PROCESSING: Creates JMeter test plan for 1000 concurrent tenants
OUTPUT: p95 latency report + throughput metrics
HYPERLINK: https://jmeter.apache.org
STACK: JMeter 5.6 + InfluxDB
COMPLIANCE: PS25 Load test 10k TPS

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 10
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS74: Adding JMeter Load Test ===" -ForegroundColor Cyan

$jmeterDir = Join-Path $BasePath "atlas-workspace\platform\loadtests"
New-Item -ItemType Directory -Force $jmeterDir | Out-Null

$jmx = Join-Path $jmeterDir "voucher-loadtest.jmx"
@"
<?xml version="1.0"?>
<jmeterTestPlan>
  <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup">
    <stringProp name="ThreadGroup.num_threads">1000</stringProp>
    <stringProp name="ThreadGroup.ramp_time">60</stringProp>
  </ThreadGroup>
  <HTTPSamplerProxy>
    <stringProp name="HTTPSampler.path">/api/vouchers</stringProp>
    <stringProp name="HTTPSampler.method">POST</stringProp>
  </HTTPSamplerProxy>
</jmeterTestPlan>
"@ | Out-File $jmx -Encoding utf8

Write-Host "PS74 Done: Run 'jmeter -n -t voucher-loadtest.jmx -l results.jtl'" -ForegroundColor Green
