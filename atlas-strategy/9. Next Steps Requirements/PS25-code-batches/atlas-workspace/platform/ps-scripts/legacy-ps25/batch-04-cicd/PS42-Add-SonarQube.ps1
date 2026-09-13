<#
.SYNOPSIS
PS25 Script: PS42-Add-SonarQube

.DESCRIPTION
INPUT: backend/pom.xml
PROCESSING: Adds Sonar Maven plugin + sonar-project.properties
OUTPUT: Code quality + coverage gates in CI
HYPERLINK: https://docs.sonarqube.org
STACK: SonarQube + JaCo + Maven
COMPLIANCE: PS25 Code Quality Gate > 80%

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 4
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS42: Adding SonarQube Integration ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$sonarPlugin = @"
    <plugin>
        <groupId>org.sonarsource.scanner.maven</groupId>
        <artifactId>sonar-maven-plugin</artifactId>
        <version>3.10.0.2594</version>
    </plugin>
"@
(Get-Content $pom) -replace '</build>', "$sonarPlugin`n </build>" | Set-Content $pom

$sonarProps = Join-Path $BasePath "sonar-project.properties"
@"
sonar.projectKey=demo-bank
sonar.host.url=http://localhost:9000
sonar.login=admin
sonar.sourceEncoding=UTF-8
sonar.java.coveragePlugin=jacoco
"@ | Out-File $sonarProps -Encoding utf8

Write-Host "PS42 Done: Run 'mvn sonar:sonar' in CI" -ForegroundColor Green
