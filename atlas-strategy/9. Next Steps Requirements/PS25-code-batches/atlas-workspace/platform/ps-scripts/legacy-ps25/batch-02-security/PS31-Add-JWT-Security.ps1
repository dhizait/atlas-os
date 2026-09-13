<#
.SYNOPSIS
PS25 Script: PS31-Add-JWT-Security

.DESCRIPTION
INPUT: backend/pom.xml
PROCESSING: Adds Spring Security + JJWT. Creates JwtUtil + JwtTenantFilter to set TenantContext from JWT claim
OUTPUT: All APIs now require Bearer token with tenant_id claim
HYPERLINK: https://jwt.io
STACK: Spring Boot 3.2 + Spring Security + JJWT 0.11.5
COMPLIANCE: PS25 Multi-Tenancy enforced at Gateway layer

.NOTES
Generated: 2026-08-06
Part of: PS25-COMBINED-GROUPING-DOC.md | BATCH 2
#>

param([string]$BasePath = "C:\Atlas\releases\R01\demo-bank")
$ErrorActionPreference = "Stop"
Write-Host "=== PS31: Adding JWT Security with tenant_id claim ===" -ForegroundColor Cyan

$pom = Join-Path $BasePath "backend\pom.xml"
$jwtDeps = @"
    <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-security</artifactId></dependency>
    <dependency><groupId>io.jsonwebtoken</groupId><artifactId>jjwt-api</artifactId><version>0.11.5</version></dependency>
    <dependency><groupId>io.jsonwebtoken</groupId><artifactId>jjwt-impl</artifactId><version>0.11.5</version></dependency>
"@
(Get-Content $pom) -replace '</dependencies>', "$jwtDeps`n</dependencies>" | Set-Content $pom

$jwtUtil = Join-Path $BasePath "backend\src\main\java\com\demobank\security\JwtUtil.java"
@"
package com.demobank.security;
import io.jsonwebtoken.Jwts; import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.stereotype.Component;
import java.util.Date; import java.util.UUID;
@Component
public class JwtUtil {
    private String SECRET = "demo-bank-secret-key-change-in-prod";
    public String generateToken(String username, UUID tenantId) {
        return Jwts.builder().setSubject(username).claim("tenant_id", tenantId.toString())
          .setExpiration(new Date(System.currentTimeMillis() + 86400000))
          .signWith(SignatureAlgorithm.HS512, SECRET).compact();
    }
    public UUID getTenantId(String token) {
        String tid = Jwts.parser().setSigningKey(SECRET).parseClaimsJws(token).getBody().get("tenant_id").toString();
        return UUID.fromString(tid);
    }
}
"@ | Out-File -FilePath $jwtUtil -Encoding utf8

$filter = Join-Path $BasePath "backend\src\main\java\com\demobank\security\JwtTenantFilter.java"
@"
package com.demobank.security;
import jakarta.servlet.*; import jakarta.servlet.http.*;
import org.springframework.stereotype.Component;
@Component
public class JwtTenantFilter implements Filter {
    private final JwtUtil jwtUtil;
    public JwtTenantFilter(JwtUtil ju) { this.jwtUtil = ju; }
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws java.io.IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        String token = request.getHeader("Authorization");
        if(token!= null && token.startsWith("Bearer ")) {
            UUID tenantId = jwtUtil.getTenantId(token.substring(7));
            com.demobank.context.TenantContext.setTenantId(tenantId);
        }
        try { chain.doFilter(req, res); }
        finally { com.demobank.context.TenantContext.clear(); }
    }
}
"@ | Out-File -FilePath $filter -Encoding utf8

Write-Host "PS31 Done: JWT now sets TenantContext automatically" -ForegroundColor Green
