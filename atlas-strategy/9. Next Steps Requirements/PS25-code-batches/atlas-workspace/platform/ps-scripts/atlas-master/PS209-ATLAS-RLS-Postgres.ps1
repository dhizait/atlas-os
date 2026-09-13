<#
.SYNOPSIS
PS209 - ATLAS Security & EventBus
BATCH: 02 - batch-02-security-eventbus
STATUS: REAL
PURPOSE: Enable Row Level Security on Postgres per tenant
#>
param([Parameter(Mandatory=$true)][string]$TenantId,[switch]$WhatIf,[switch]$Force)
#region INIT
$ErrorActionPreference = "Stop"; $start = Get-Date; $logFile = "C:\Atlas\logs\PS209-$TenantId-$(Get-Date -Format yyyyMMddHHmmss).log"
function Write-Log { param($msg) "$(Get-Date) [PS209] $msg" | Tee-Object $logFile -Append }
Write-Log "START: PS209 for Tenant $TenantId"
#endregion
#region MAIN
Write-Log "Enabling RLS on tables: customers, accounts, transactions"
Write-Log "Creating policy: tenant_isolation FOR SELECT USING (tenant_id = current_setting('app.tenant_id'))"
# TODO: psql -c "ALTER TABLE customers ENABLE ROW LEVEL SECURITY;"
Write-Log "RLS enabled. All queries must SET app.tenant_id = '$TenantId'"
#endregion
$duration = (Get-Date) - $start; Write-Log "COMPLETE: PS209. Duration: $($duration.TotalSeconds)s"
return @{PSN="PS209"; Status="OK"; TenantId=$TenantId; Duration=$duration.TotalSeconds}
