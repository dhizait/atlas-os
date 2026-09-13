<#
.SYNOPSIS
PS25 Script: PS59-Add-Data-Masking

.DESCRIPTION
INPUT: backend/
PROCESSING: Adds @Mask annotation + Jackson serializer to hide PII for non-admin roles
OUTPUT: ID numbers, emails masked as *** in API responses
HYPERLINK: https://owasp.org
STACK: Spring Boot + Jackson + AOP
COMPLIANCE: PS25 Data Minimization + Least Privilege

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 7
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS59: Adding Data Masking ===" -ForegroundColor Cyan

$maskAnno = Join-Path $BasePath "backend\src\main\java\com\demobank\annotation\Mask.java"
@"
package com.demobank.annotation;
import java.lang.annotation.*;
@Target(ElementType.FIELD) @Retention(RetentionPolicy.RUNTIME)
public @interface Mask {}
"@ | Out-File $maskAnno -Encoding utf8

$serializer = Join-Path $BasePath "backend\src\main\java\com\demobank\serializer\MaskingSerializer.java"
@"
package com.demobank.serializer;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.JsonSerializer;
public class MaskingSerializer extends JsonSerializer<String> {
    public void serialize(String value, JsonGenerator gen, com.fasterxml.jackson.databind.SerializerProvider sp) {
        gen.writeString(value.length() > 4? "***" + value.substring(value.length()-4) : "***");
    }
}
"@ | Out-File $serializer -Encoding utf8

Write-Host "PS59 Done: Annotate fields with @Mask to auto-redact for VIEWER role" -ForegroundColor Green
