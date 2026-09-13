import json, shutil, os

OLD_ROOT = "../Atlas/releases/R01/work_desk" # <--- CHANGE THIS
NEW_ROOT = "."
MAP_FILE = "migration_map.json"

def copy_dir(src, dst):
    if not os.path.exists(src):
        print(f"SKIP: {src} not found")
        return
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    if os.path.exists(dst): 
        shutil.rmtree(dst)
    shutil.copytree(src, dst)
    print(f"COPIED: {src} -> {dst}")

def main():
    with open(MAP_FILE) as f:
        migration_map = json.load(f)

    print("=== 1. MIGRATING PLATFORM ===")
    for item in migration_map["platform"]:
        copy_dir(os.path.join(OLD_ROOT, item["old"]), os.path.join(NEW_ROOT, item["new"]))

    print("\n=== 2. MIGRATING DRIVERS ===")
    for driver in migration_map["drivers"]:
        driver_name = driver["name"]
        driver_path = f"drivers/{driver_name}"
        old_root = os.path.join(OLD_ROOT, driver["old_root"])

        # ALL DRIVERS NOW FLAT: copy everything in old_root -> drivers/{name}/api/
        if os.path.exists(old_root):
            for svc_folder in os.listdir(old_root):
                svc_path = os.path.join(old_root, svc_folder)
                if os.path.isdir(svc_path):
                    copy_dir(svc_path, os.path.join(driver_path, "api", svc_folder))
        else:
            print(f"SKIP: {old_root} not found")

        # Copy external services if any
        for svc in driver.get("ext_services", []):
            svc_path = os.path.join(OLD_ROOT, svc)
            svc_name = svc.split("/")[-1]
            copy_dir(svc_path, os.path.join(driver_path, "api", svc_name))

    print("\n=== 3. MIGRATING APPS ===")
    for item in migration_map["apps"]:
        copy_dir(os.path.join(OLD_ROOT, item["old"]), os.path.join(NEW_ROOT, item["new"]))

    print("\n=== DONE ===")
    print("NG Result: drivers/ng-experience/api/svc101-Digital-Voucher-Service")
    print("Next: Extract batches to drivers/*/batches/*.py")

if __name__ == "__main__":
    main()