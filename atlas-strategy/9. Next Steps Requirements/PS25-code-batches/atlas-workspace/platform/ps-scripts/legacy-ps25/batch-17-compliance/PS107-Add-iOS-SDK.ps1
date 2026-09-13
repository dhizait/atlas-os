<#
.SYNOPSIS
PS25 Script: PS107-Add-iOS-SDK

.DESCRIPTION
INPUT: None
PROCESSING: Creates Swift Package for DemoBank API
OUTPUT: DemoBankSDK for iOS apps. Handles tenant_id header
HYPERLINK: https://developer.apple.com/swift
STACK: Swift 5.9 + URLSession
COMPLIANCE: PS25 Partner SDK

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 17
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS107: Adding iOS SDK ===" -ForegroundColor Cyan

$sdkDir = Join-Path $BasePath "sdk\ios\DemoBankSDK"
New-Item -ItemType Directory -Force $sdkDir | Out-Null

$swift = Join-Path $sdkDir "DemoBankClient.swift"
@"
import Foundation
public class DemoBankClient {
    private let tenantId: String
    public init(tenantId: String) { self.tenantId = tenantId }

    public func createVoucher(amount: Decimal, completion: @escaping (Result<Data, Error>) -> Void) {
        var req = URLRequest(url: URL(string: "https://api.demo-bank.com/api/vouchers")!)
        req.httpMethod = "POST"
        req.setValue(tenantId, forHTTPHeaderField: "X-Tenant-ID")
        URLSession.shared.dataTask(with: req, completionHandler: completion).resume()
    }
}
"@ | Out-File $swift -Encoding utf8

Write-Host "PS107 Done: Swift Package at sdk/ios/DemoBankSDK" -ForegroundColor Green
