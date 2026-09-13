import os

BASE = "atlas-os"

DIRS = [
    # ... all other dirs same ...
    "drivers/ng-experience/api", "drivers/ng-experience/db/migrations", "drivers/ng-experience/batches", # FLAT
    # ... rest same ...
]

FILES = {
    "migration_map.json": '''{
  "version": "1.2",
  "description": "Atlas R01 to Atlas-OS v2.0 Migration Map - NG FLAT",
  "drivers": [
    {"name": "customer", "old_root": "demo-bank-services/cm"},
    {"name": "product", "old_root": "demo-bank-services/pm"},
    {"name": "ng-experience", "old_root": "demo-bank-services/ng", "flat": true},
    {"name": "core-banking", "old_root": "demo-bank-services/tm"},
    {"name": "lending", "old_root": "demo-bank-services/tm"},
    {"name": "payments", "old_root": "demo-bank-services/tm"},
    {"name": "compliance", "old_root": "demo-bank-services/tm"},
    {"name": "integrations", "old_root": "demo-bank-services/am"},
    {"name": "intelligence", "old_root": "demo-bank-services/dm"}
  ]
}''',
    "drivers/ng-experience/README.md": '''# NG-EXPERIENCE DRIVER - FLAT STRUCTURE

All svcXXX services live directly in /api
svc101-svc108 = Wave1 Digital Rails
svc201-svc208 = Wave2 AI + Wealth  
svc301-svc315 = Wave3 Web3 + R&D

Naming convention retains svcXXX for traceability
''',
    # ... rest same ...
}