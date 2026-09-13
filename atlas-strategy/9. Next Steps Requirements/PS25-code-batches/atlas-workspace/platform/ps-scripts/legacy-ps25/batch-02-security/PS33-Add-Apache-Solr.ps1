<#
.SYNOPSIS
PS33-Add-Apache-Solr.ps1 - Adds Apache Solr 9.6 for tenant-aware voucher search
.DESCRIPTION
Creates Solr docker service, schema with tenant_id, Spring Boot Solr client, and Kafka consumer
REQUIRES: PS25 complete. Kafka + TenantContext + docker-compose.yml must exist
USAGE:
.\PS33-Add-Apache-Solr.ps1 -BasePath "C:\Atlas\releases\R01\demo-bank" [-Force]
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BasePath,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$BeRoot = Join-Path $BasePath "backend"
$ComposeFile = Join-Path $BasePath "docker-compose.yml"
$SolrConfigDir = Join-Path $BasePath "solr-config\voucher_conf"

Write-Host "=== PS33: Adding Apache Solr ===" -ForegroundColor Cyan

# 0. Pre-checks
if (!(Test-Path $ComposeFile)) { throw "docker-compose.yml not found at $ComposeFile" }
if (!(Test-Path $BeRoot)) { throw "backend folder not found at $BeRoot. Run PS01-PS25 first" }

# 1. Add Solr service to docker-compose.yml - Idempotent
Write-Host "Step 1/4: Updating docker-compose.yml"
$composeContent = Get-Content $ComposeFile -Raw
if ($composeContent -notlike "*solr:*") {
    $solrService = @"

  solr:
    image: solr:9.6
    container_name: demo-bank-solr
    ports:
      - "8983:8983"
    volumes:
      -./solr-data:/var/solr/data
      -./solr-config:/opt/solr/server/solr/configsets
    command: solr-precreate vouchers /opt/solr/server/solr/configsets/voucher_conf
    environment:
      - SOLR_HEAP=512m
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8983/solr/"]
      interval: 10s
      timeout: 5s
      retries: 5
"@
    Add-Content -Path $ComposeFile -Value $solrService
    Write-Host " Added solr service" -ForegroundColor Green
} else {
    Write-Host " Solr service already exists. Skipping." -ForegroundColor Yellow
}

# 2. Create Solr Schema with tenant_id
Write-Host "Step 2/4: Creating Solr schema"
New-Item -ItemType Directory -Force $SolrConfigDir | Out-Null
$schema = @'
<?xml version="1.0" encoding="UTF-8"?>
<schema name="vouchers" version="1.6">
  <field name="id" type="string" indexed="true" stored="true" required="true" />
  <field name="tenant_id" type="string" indexed="true" stored="true" required="true" />
  <field name="voucher_no" type="string" indexed="true" stored="true" />
  <field name="narration" type="text_en" indexed="true" stored="true" />
  <field name="amount" type="pdouble" indexed="true" stored="true" />
  <field name="status" type="string" indexed="true" stored="true" />
  <field name="posted_date" type="pdate" indexed="true" stored="true" />
  <field name="posted_by" type="string" indexed="true" stored="true" />
  <uniqueKey>id</uniqueKey>
</schema>
'@
$schema | Out-File (Join-Path $SolrConfigDir "schema.xml") -Encoding utf8 -Force

$solrConfig = @'
<config>
  <luceneMatchVersion>9.6</luceneMatchVersion>
  <dataDir>${solr.data.dir:}</dataDir>
</config>
'@
$solrConfig | Out-File (Join-Path $SolrConfigDir "solrconfig.xml") -Encoding utf8 -Force

# 3. Add Solr Dependency to pom.xml
Write-Host "Step 3/4: Adding Solr dependency"
$pom = Join-Path $BeRoot "pom.xml"
$solrDep = @"
    <!-- PS33: Apache Solr -->
    <dependency>
        <groupId>org.apache.solr</groupId>
        <artifactId>solr-solrj</artifactId>
        <version>9.6.0</version>
    </dependency>
"@
$content = Get-Content $pom -Raw
if ($content -notlike "*solr-solrj*") {
    $content -replace '</dependencies>', "$solrDep`n</dependencies>" | Set-Content $pom -Encoding utf8
    Write-Host " Added solr-solrj dependency" -ForegroundColor Green
} else {
    Write-Host " Solr dependency already exists. Skipping." -ForegroundColor Yellow
}

# 4. Create Solr Service + Kafka Consumer
Write-Host "Step 4/4: Creating Solr Services"
$searchPkg = Join-Path $BeRoot "src\main\java\com\demobank\search"
$eventPkg = Join-Path $BeRoot "src\main\java\com\demobank\event"
New-Item -ItemType Directory -Force $searchPkg | Out-Null
New-Item -ItemType Directory -Force $eventPkg | Out-Null

# Solr Document Entity
@'
package com.demobank.search;
import org.apache.solr.client.solrj.beans.Field;
public class VoucherDoc {
    @Field private String id;
    @Field("tenant_id") private String tenantId;
    @Field("voucher_no") private String voucherNo;
    @Field private String narration;
    @Field private Double amount;
    @Field private String status;
    @Field("posted_date") private java.time.LocalDateTime postedDate;
    @Field("posted_by") private String postedBy;
    // Getters and Setters omitted for brevity
    public String getId() { return id; } public void setId(String id) { this.id = id; }
    public String getTenantId() { return tenantId; } public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    public String getVoucherNo() { return voucherNo; } public void setVoucherNo(String voucherNo) { this.voucherNo = voucherNo; }
    public String getNarration() { return narration; } public void setNarration(String narration) { this.narration = narration; }
    public Double getAmount() { return amount; } public void setAmount(Double amount) { this.amount = amount; }
    public String getStatus() { return status; } public void setStatus(String status) { this.status = status; }
}
'@ | Out-File (Join-Path $searchPkg "VoucherDoc.java") -Encoding utf8 -Force

# Solr Service with Tenant Filter
@'
package com.demobank.search;
import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.springframework.stereotype.Service;
import java.util.List;
@Service
public class VoucherSearchService {
    private final SolrClient solrClient;
    public VoucherSearchService(SolrClient solrClient) { this.solrClient = solrClient; }

    public void indexVoucher(VoucherDoc doc) throws Exception {
        solrClient.addBean("vouchers", doc);
        solrClient.commit("vouchers");
    }

    public QueryResponse search(String q) throws Exception {
        String tenantId = com.demobank.context.TenantContext.getTenantId();
        SolrQuery query = new SolrQuery();
        query.setQuery("narration:" + q + " AND tenant_id:" + tenantId);
        return solrClient.query("vouchers", query);
    }
}
'@ | Out-File (Join-Path $searchPkg "VoucherSearchService.java") -Encoding utf8 -Force

# Solr Config Bean
@'
package com.demobank.config;
import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.impl.HttpSolrClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
@Configuration
public class SolrConfig {
    @Bean
    public SolrClient solrClient() {
        return new HttpSolrClient.Builder("http://solr:8983/solr").build();
    }
}
'@ | Out-File (Join-Path $searchPkg "SolrConfig.java") -Encoding utf8 -Force

# Kafka Consumer
@'
package com.demobank.event;
import com.demobank.search.VoucherDoc;
import com.demobank.search.VoucherSearchService;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
@Service
public class SolrIndexConsumer {
    private final VoucherSearchService searchService;
    public SolrIndexConsumer(VoucherSearchService ss) { this.searchService = ss; }

    @KafkaListener(topics = "voucher.posted", groupId = "solr-indexer")
    public void handleVoucherPosted(VoucherPostedEvent event) throws Exception {
        VoucherDoc doc = new VoucherDoc();
        doc.setId(event.getId());
        doc.setTenantId(event.getTenantId());
        doc.setVoucherNo(event.getVoucherNo());
        doc.setNarration(event.getNarration());
        doc.setAmount(event.getAmount());
        doc.setStatus(event.getStatus());
        searchService.indexVoucher(doc);
    }
}
'@ | Out-File (Join-Path $eventPkg "SolrIndexConsumer.java") -Encoding utf8 -Force

Write-Host "PS33 COMPLETE: Solr added." -ForegroundColor Green
Write-Host "Next: docker compose up -d solr" -ForegroundColor Cyan
Write-Host "Then: mvn clean install in $BeRoot" -ForegroundColor Cyan