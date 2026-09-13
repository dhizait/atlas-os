# ATLAS OS v2.0 - POST MIGRATION CHECKLIST
Last Updated: 2026-09-12

## PHASE 0: VERIFY COPY [Automated by migrate_from_r01.py]
- [ ] All 9 drivers exist with /api /batches /db folders
- [ ] All 31 NG svcXXX services in drivers/ng-experience/api/
- [ ] Platform services in platform/
- [ ] Apps in apps/

## PHASE 1: BATCH EXTRACTION [Manual]
Rule: Every cron/quartz/job must move to drivers/{driver}/batches/{name}.py
Owner: Platform Team

### customer
- [ ] cm009-Watchlist-Screening -> batches/watchlist_screen.py
- [ ] cm002-KYC-Service -> batches/kyc_expiry.py

### product
- [ ] pm026-Eligibility-Rules -> batches/eligibility_recalc.py

### core-banking
- [ ] accounts-mgt/batch/interest -> batches/interest_accrual.py
- [ ] gl-ops-mgt/batch/eod -> batches/eod_close.py
- [ ] transaction-mgt/batch/recon -> batches/gl_posting.py

### lending
- [ ] lending-mgt/batch/delinquency -> batches/delinquency_check.py
- [ ] lending-mgt/batch/npl -> batches/npl_provision.py

### payments
- [ ] payments-mgt/batch/settlement -> batches/settlement_recon.py
- [ ] payments-mgt/batch/disburse -> batches/batch_disbursement.py

### compliance
- [ ] compliance-risk-mgt/batch/aml -> batches/aml_screen.py

### ng-experience
- [ ] svc103-Reward-Loyalty-Service/batch -> batches/loyalty_points_calc.py
- [ ] svc208-Campaign-Engine-Service/cron -> batches/campaign_trigger.py

### intelligence
- [ ] im015-Anomaly-Detect -> batches/anomaly_daily_scan.py

## PHASE 2: DB SCHEMA MIGRATION
Rule: 1 DB, multiple schemas
- [ ] Create schema: customer, product, core_banking, lending, payments, compliance, ng_experience, integrations, intelligence
- [ ] Move tables: UPDATE cm001-Customer-Profile SET search_path = customer
- [ ] Update all datasource.yml in each driver/api to use schema

## PHASE 3: API GATEWAY ROUTING
- [ ] Add route: /api/customer/* -> customer driver
- [ ] Add route: /api/ng/* -> ng-experience driver
- [ ] Add route: /api/core/* -> core-banking driver
- [ ] Deprecate old svc101 URLs

## PHASE 4: WORKFLOW ENGINE
- [ ] Migrate atlas-workspace/orchestration -> platform/workflow-engine/workflows/eod.yml
- [ ] Register all batches in platform/workflow-engine/ with schedule
- [ ] Test: python scripts/run_driver_batch.py core_banking.interest_accrual

## PHASE 5: OBSERVABILITY
- [ ] Each driver/api must emit Event to platform/event-ledger on write
- [ ] Add health check: /api/{driver}/health
- [ ] Add logs to platform/observability/loki with tag driver={name}

## PHASE 6: DECOMMISSION OLD
- [ ] Stop demo-bank-services/*
- [ ] Archive R01 to /archive/R01-final
- [ ] Update CI/CD to build from atlas-os/

## SIGN-OFF
| Phase | Owner | Date | Status |
| --- | --- | --- | --- |
| 0. Copy Verify | | | [ ] |
| 1. Batch Extract | | | [ ] |
| 2. DB Schema | | | [ ] |
| 3. API Gateway | | | [ ] |
| 4. Workflows | | | [ ] |
| 5. Observability | | | [ ] |
| 6. Decommission | | | [ ] |