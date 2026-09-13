# Atlas-OS Strategy

**The single source of truth for Atlas Operating System v3.0**

Atlas-OS is the re-engineering of T24 into 9 flat drivers, 1 event bus, and 200+ rewritten core functionalities in Go.

---

## 📁 Repository Structure

D:.
|   atlas-repo-tree.txt
|   
\---atlas-os
    \---atlas-strategy
        |   1. Atlas Strategy 1.txt
        |   10. Atlas Strategy One Stop Shop Principle.txt
        |   11. Strategy Wrap up and PS25 Realignment.txt
        |   2. Atlas Strategy 1 + 2.txt
        |   3. Atlas Strategy 1 + 2 + 3.txt
        |   4. Atlas Strategy Final.txt
        |   5. Atlas Execution Pack - All 4 Drilldowns.txt
        |   6. Next Steps.txt
        |   7. From KE, NG, ZA, GCC.txt
        |   8. Miscellaneous to Consider.txt
        |   9. Atlas Greenfield, Brownfield, Core Roadmap.txt
        |   README.md
        |   
        +---1. From T24 + Intellect + Mambu
        |       Atlas Strategy 1 PAGER - Basis 0.txt
        |       Atlas Strategy 1 PAGER - Basis 1.txt
        |       Atlas Strategy 1 PAGER - Basis 2.txt
        |       
        +---10. Atlas Strategy One Stop Shop Principle
        |       10. Atlas Strategy One Stop Shop Principle.txt
        |       
        +---12. Strategy Wrap up and PS25 Realignment
        |       0. Strategy Wrap up and PS25 Realignment.txt
        |       1. Response to Strategy Wrap up and PS25 Realignment.txt
        |       
        +---13. Gapping IoT & Blockchain especially for Trade Finance
        +---14 Atlas Strategy v6. 1 - One Stop Shop
        |       0. Atlas Strategy v6. 1 - One Stop Shop.txt
        |       1. What we mean by Next 3 Billion.txt
        |       2. All batches Alpha to Omega for Atlas Strategy.txt
        |       3. Next Steps.txt
        |       4. Why Atlas catches attention day 1.txt
        |       5. Atlas Strategy v6. 2 - One Stop Shop.txt
        |       6. Atlas Strategy v6. 2.1 - One Stop Shop.txt
        |       7. Going Atlas OS + Molecular.txt
        |       8. .Atlas Strategy Document v6.2.txt
        |       PHASE_MANIFEST_ATLAS_v6.1.json
        |       PHASE_MANIFEST_ATLAS_v6.2.json
        |       PHASE_MANIFEST_ATLAS_v6.3.json
        |       
        +---15. Atlas OS Brain Storming with AI
        |       0. Next after Atlas Kernel.txt
        |       1. Atlas OS Demo Bank v1. 0 Scope & Acceptance Checklist.txt
        |       10. Comparison with Thought Machine.txt
        |       11. Comparison to other Kernel. Builders.txt
        |       12. The Art of Linux Programming by Eric S Raymond.txt
        |       13. The Drivers Layer.txt
        |       14. Full Operating System Architecture.txt
        |       15. Atlas Repo Review.txt
        |       16. Atlas Repo extensibility.txt
        |       17. Migration Map.txt
        |       18. Revised Migration Map.txt
        |       2. Pitching against Temenos Depth.txt
        |       3. 1-Pager Atlas OS v1. 0 vs Temenos Transact.txt
        |       4. Let's go. Kernel first.txt
        |       5. 1 Week Kernel Sprimt.txt
        |       6. What to Learn from Unix.txt
        |       7. Cutting down batches in the kernel.txt
        |       8. Next Steps.txt
        |       9. Batches that we cut off as Linux Drivers.txt
        |       
        +---16. Scaffold Atlas OS Repo
        |       migrate_from_r01.py
        |       migration_map.json
        |       post_migration_checklist.md
        |       scaffold_atlas_os.py
        |       
        +---2. From Other Bank SWs
        |       Atlas Strategy 1 PAGER II - Basis.txt
        |       Atlas Strategy 1 Pager IItxt
        |       
        +---3. From Fintechs
        |       Atlas Strategy 1 PAGER III - Basis.txt
        |       
        +---4. From KG, NG, ZA, GCC
        |       Atlas Strategy 1 PAGER IV - Basis.txt
        |       
        +---5. US Tier 1 Market
        |       US Tier 1 Market - Avoid till 2030.txt
        |       
        +---6. Drilldowns
        |       ARCHITECTURE.md
        |       CORE.md
        |       PHASE_MANIFEST_ATLAS.json
        |       SUMMARY.md
        |       
        +---7. Atlas Greenfield, Brownfield, Core Roadmap
        |       0. Atlas Greenfield, Brownfield, Core Roadmap.txt
        |       1. Java or Go for T24 Core.txt
        |       
        +---8. Meta AI Review
        |       0. Meta AI Review.txt
        |       1. Option 1 & 2.txt
        |       2. Next Steps.txt
        |       
        +---9. Next Steps Requirements
        |   |   Atlas Strategy v5.0. Requirement - One by Ones.txt
        |   |   Atlas Strategy v5.0. Requirements.txt
        |   |   Atlas Strategy v5.0.txt
        |   |   Atlas-tree.txt
        |   |   Atlas_Feature_Target_Master_v1.0.csv
        |   |   Atlas_Tree_Full_Domains_20260904_234720.csv
        |   |   ps25-scripts Extract Request.txt
        |   |   ps25-scripts-tree.txt
        |   |   R17AMR Tree Finalization.txt
        |   |   R17AMR_tree.txt
        |   |   
        |   \---PS25-code-batches
        |       |   atlas-workspace.7z
        |       |   BATCH_01_PS1.txt
        |       |   BATCH_02_PS1.txt
        |       |   BATCH_03_PS1.txt
        |       |   BATCH_04_PS1.txt
        |       |   BATCH_05_PS1.txt
        |       |   BATCH_06_PS1.txt
        |       |   BATCH_07_PS1.txt
        |       |   BATCH_08_PS1.txt
        |       |   BATCH_09_PS1.txt
        |       |   BATCH_10_PS1.txt
        |       |   BATCH_11_PS1.txt
        |       |   BATCH_12_PS1.txt
        |       |   BATCH_13_PS1.txt
        |       |   BATCH_14_PS1.txt
        |       |   BATCH_15_PS1.txt
        |       |   BATCH_16_PS1.txt
        |       |   BATCH_17_PS1.txt
        |       |   BATCH_18_PS1.txt
        |       |   BATCH_19_PS1.txt
        |       |   COLLECTION-MANIFEST-20260905-022301.txt
        |       |   README_BATCHES.txt
        |       |   
        |       \---atlas-workspace
        |           +---docs
        |           |       PS25-COMBINED-GROUPING-DOC.md
        |           |       
        |           +---orchestration
        |           |       Build-All-Atlas-PSNs.ps1
        |           |       PS-ATLAS-MASTER-RUN.ps1
        |           |       PS-MASTER-RUN.ps1
        |           |       PS100-Report-Generator.ps1
        |           |       PS102-Create-Audit-Batches.ps1
        |           |       PS98-ATLAS-BackupRestore.ps1
        |           |       PS98-BackupRestore.ps1
        |           |       PS99-Validate-And-Cleanup.ps1
        |           |       README.md
        |           |       RUN-ALL-BATCHES.ps1
        |           |       
        |           \---platform
        |               |   ps-scripts.7z
        |               |   
        |               +---configs
        |               |       alerts.yml
        |               |       grafana-dashboard.json
        |               |       prometheus.yml
        |               |       
        |               \---ps-scripts
        |                   |   ps25-scripts-tree.txt
        |                   |   
        |                   +---atlas-master
        |                   +---code-batches
        |                   +---code_archive_back
        |                   \---legacy-ps25
        |                       +---audit-batches
        |                       +---backend
        |                       +---batch-04-cicd
        |                       +---frontend
        |                       |       .env
        |                       |       
        |                       \---root
        \---99. Miscellaneous to Consider
                1. Low Code vs Product as Code.txt
                2. Low Code  vs Product as ode vs Temenos AA.txt
                3. Altova Enterprise for product. yaml.txt
                4. ISO2002 The Altova way Atlas.txt
                
