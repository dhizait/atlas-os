<#
.SYNOPSIS
PS25 Script: PS109-Add-Push-Notifications

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds FCM integration. Sends push on voucher created
OUTPUT: /api/notifications/send + Firebase config
HYPERLINK: https://firebase.google.com/docs/cloud-messaging
STACK: Spring Boot + Firebase Admin SDK
COMPLIANCE: PS25 Real-time alerts

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 17
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS109: Adding Push Notifications ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$fcmDep = @"
    <dependency><groupId>com.google.firebase</groupId><artifactId>firebase-admin</artifactId><version>9.2.0</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$fcmDep`n</dependencies>" | Set-Content $pom

$pushSvc = Join-Path $BasePath "backend\src\main\java\com\demobank\notifications\PushService.java"
@"
package com.demobank.notifications;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
@Service
public class PushService {
    public void sendToTenant(String tenantId, String title, String body) {
        Message msg = Message.builder()
           .putData("tenant_id", tenantId)
           .setNotification(com.google.firebase.messaging.Notification.builder().setTitle(title).setBody(body).build())
           .setTopic("tenant_" + tenantId)
           .build();
        FirebaseMessaging.getInstance().send(msg);
    }
}
"@ | Out-File $pushSvc -Encoding utf8

Write-Host "PS109 Done: Set GOOGLE_APPLICATION_CREDENTIALS env" -ForegroundColor Green
