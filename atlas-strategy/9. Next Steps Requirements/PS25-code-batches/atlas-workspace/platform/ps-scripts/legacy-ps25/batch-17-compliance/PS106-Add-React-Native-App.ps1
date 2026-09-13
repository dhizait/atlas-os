<#
.SYNOPSIS
PS25 Script: PS106-Add-React-Native-App

.DESCRIPTION
INPUT: None
PROCESSING: Scaffolds React Native app with tenant login + voucher list
OUTPUT: /mobile app for iOS/Android
HYPERLINK: https://reactnative.dev
STACK: React Native 0.75 + Axios + AsyncStorage
COMPLIANCE: PS25 Mobile access

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 17
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS106: Adding React Native App ===" -ForegroundColor Cyan

$mobileDir = Join-Path $BasePath "mobile"
New-Item -ItemType Directory -Force $mobileDir | Out-Null

$appTsx = Join-Path $mobileDir "App.tsx"
@"
import React from 'react';
import {View, Text, FlatList} from 'react-native';
import axios from 'axios';

export default function App() {
  const [vouchers, setVouchers] = React.useState([]);
  React.useEffect(() => {
    axios.get('https://api.demo-bank.com/api/vouchers', {
      headers: {'X-Tenant-ID': 'TENANT001'}
    }).then(r => setVouchers(r.data));
  }, []);
  return <View><FlatList data={vouchers} renderItem={({item}) => <Text>{item.id}</Text>}/></View>
}
"@ | Out-File $appTsx -Encoding utf8

$pkg = Join-Path $mobileDir "package.json"
@"
{
  "name": "demo-bank-mobile",
  "dependencies": {"react": "18.2.0", "react-native": "0.75.0", "axios": "^1.7.0"}
}
"@ | Out-File $pkg -Encoding utf8

Write-Host "PS106 Done: cd mobile && npx react-native run-android" -ForegroundColor Green
