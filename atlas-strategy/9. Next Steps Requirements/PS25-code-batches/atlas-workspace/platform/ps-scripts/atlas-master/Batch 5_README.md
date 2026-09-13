# batch-05-payments-channels
**Batch**: 05 | **Range**: PS225-PS230 | **Theme**: Payments & Channels | **Status**: STUB

## Workers
- PS225: Payments Orchestrator
- PS226: Cards Processor
- PS227: Mobile Money
- PS228: POS Gateway
- PS229: Switch Adapter
- PS230: Payments Reconciliation

## Purpose
All payment rails. Depends on Batch 04 Core APIs and Batch 02 EventBus.
Multi-tenant via Kafka topics: atlas.$TenantId.*
