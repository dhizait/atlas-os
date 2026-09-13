#!/usr/bin/env python3
"""
ATLAS R01 PS25: Code Batcher v2.1.0
Purpose: BACKUP old code-batches -> BATCH ps1 into groups of 10 -> Separate MDs
Rule:
 1. Only.ps1 and.md files
 2. PS1s: 10 per batch txt file
 3. MDs: 1 combined README_BATCHES.txt
 4. Backup to code_archive_back\{timestamp}
Usage:
  python PS25-Collect-Code-Batches.py
"""
import shutil
from pathlib import Path
from datetime import datetime

ROOT = Path(__file__).resolve().parent
SRC_MASTER = ROOT / "atlas-master"
SRC_LEGACY = ROOT / "legacy-ps25"
BATCHES = ROOT / "code-batches"
BACKUP_ROOT = ROOT / "code_archive_back"

BATCH_SIZE = 10 # CHANGED FROM 5 TO 10
ts = datetime.now().strftime("%Y%m%d-%H%M%S")

def get_all_source_files():
    """Collect all.ps1 and.md from master + legacy batches"""
    ps1_files = []
    md_files = []

    for src in [SRC_MASTER, SRC_LEGACY]:
        if not src.exists(): continue
        if src.name == "atlas-master":
            ps1_files.extend(sorted(src.glob("*.ps1")))
            md_files.extend(sorted(src.glob("*.md")))
        else: # legacy-ps25 has subfolders
            for item in src.rglob("*"):
                if item.is_file():
                    if item.suffix == ".ps1": ps1_files.append(item)
                    elif item.suffix == ".md": md_files.append(item)

    # Sort ps1 by name for consistent batching
    ps1_files.sort(key=lambda x: x.name)
    md_files.sort(key=lambda x: x.name)
    return ps1_files, md_files

def backup_old_batches():
    """Move existing code-batches to code_archive_back\{timestamp}"""
    if not BATCHES.exists() or not any(BATCHES.iterdir()):
        print("[BACKUP] No existing code-batches to backup")
        return

    backup_dir = BACKUP_ROOT / ts
    backup_dir.mkdir(parents=True, exist_ok=True)
    for item in BATCHES.iterdir():
        shutil.move(str(item), backup_dir / item.name)
    print(f"[BACKUP] Old batches -> {backup_dir}")

def build_ps1_batches(ps1_files, batches_dir, manifest):
    """Split PS1s into batches of 10"""
    total_batches = 0
    for i in range(0, len(ps1_files), BATCH_SIZE):
        batch_files = ps1_files[i:i + BATCH_SIZE]
        batch_num = (i // BATCH_SIZE) + 1
        batch_path = batches_dir / f"BATCH_{batch_num:02d}_PS1.txt"

        with open(batch_path, "w", encoding="utf-8") as batch:
            batch.write(f'"""\nATLAS R01 BATCH {batch_num:02d} - PS1 SCRIPTS\nGenerated: {ts}\nContains: {len(batch_files)} scripts\nBatchSize: {BATCH_SIZE}\nWARNING: REVIEW ONLY. DO NOT RUN THIS FILE.\nRun individual scripts from atlas-master/ or legacy-ps25/\n"""\n\n')

            for src_file in batch_files:
                rel_path = src_file.relative_to(ROOT)
                batch.write(f'# {"="*70}\n# SOURCE FILE: {rel_path}\n# {"="*70}\n\n')
                try:
                    batch.write(src_file.read_text(encoding="utf-8"))
                except Exception as e:
                    batch.write(f"# ERROR READING FILE: {e}")
                batch.write(f'\n\n# --- END OF {src_file.name} ---\n\n')

        manifest.append(f"BATCH_{batch_num:02d}_PS1.txt: {[f.name for f in batch_files]}")
        print(f"[BATCHED] {batch_path.name} -> {len(batch_files)} scripts")
        total_batches += 1

    manifest.append(f"TOTAL_PS1_BATCHES: {total_batches}")
    manifest.append(f"TOTAL_PS1_FILES: {len(ps1_files)}")

def build_md_batch(md_files, batches_dir, manifest):
    """Combine all MDs into 1 file"""
    if not md_files:
        manifest.append("TOTAL_MD_FILES: 0")
        return

    md_path = batches_dir / "README_BATCHES.txt"
    with open(md_path, "w", encoding="utf-8") as md_batch:
        md_batch.write(f'"""\nATLAS R01 DOCUMENTATION BATCH\nGenerated: {ts}\nContains: {len(md_files)} MD files\n"""\n\n')

        for src_file in md_files:
            rel_path = src_file.relative_to(ROOT)
            md_batch.write(f'# {"="*70}\n# SOURCE FILE: {rel_path}\n# {"="*70}\n\n')
            try:
                md_batch.write(src_file.read_text(encoding="utf-8"))
            except Exception as e:
                md_batch.write(f"# ERROR READING FILE: {e}")
            md_batch.write(f'\n\n# --- END OF {src_file.name} ---\n\n')

    manifest.append(f"README_BATCHES.txt: {[f.name for f in md_files]}")
    manifest.append(f"TOTAL_MD_FILES: {len(md_files)}")
    print(f"[BATCHED] {md_path.name} -> {len(md_files)} docs")

def main():
    print("="*50)
    print("[PS25] ATLAS Code Batcher v2.1.0 - 10 per Batch")
    print("="*50)

    ps1_files, md_files = get_all_source_files()
    if not ps1_files and not md_files:
        print(f"[FATAL] No.ps1 or.md files found in {SRC_MASTER} or {SRC_LEGACY}")
        exit(1)

    print(f"[FOUND] {len(ps1_files)} PS1 files, {len(md_files)} MD files")

    BATCHES.mkdir(exist_ok=True)
    BACKUP_ROOT.mkdir(exist_ok=True)

    # 1. Backup
    backup_old_batches()

    # 2. Clear
    for item in BATCHES.iterdir():
        if item.is_file(): item.unlink()
        elif item.is_dir(): shutil.rmtree(item)

    manifest = [
        f"Timestamp: {ts}",
        f"Source: {SRC_MASTER}, {SRC_LEGACY}",
        f"BatchSize: {BATCH_SIZE}"
    ]

    # 3. Build
    build_ps1_batches(ps1_files, BATCHES, manifest)
    build_md_batch(md_files, BATCHES, manifest)

    # 4. Manifest
    manifest_path = BATCHES / f"COLLECTION-MANIFEST-{ts}.txt"
    manifest_path.write_text("\n".join(manifest), encoding="utf-8")

    print(f"[MANIFEST] {manifest_path.name}")
    print(f"[DONE] Code batches created in {BATCHES}")
    print(f"[BACKUP] History in {BACKUP_ROOT}")

if __name__ == "__main__": main()