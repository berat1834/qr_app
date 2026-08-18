import os
import shutil

src_dir = r"C:\Users\berat\OneDrive\Masaüstü\projelerim"
dest_dir = r"c:\src\QRKOD Proje\qr_app\docs\screenshots"

os.makedirs(dest_dir, exist_ok=True)

files_copied = 0
failed_files = []

for filename in os.listdir(src_dir):
    if filename.lower().endswith(('.png', '.jpeg', '.jpg', '.pdf')):
        src_file = os.path.join(src_dir, filename)
        dest_file = os.path.join(dest_dir, filename)
        if os.path.exists(dest_file):
            continue
        try:
            shutil.copy2(src_file, dest_file)
            files_copied += 1
            print(f"Copied {filename}")
        except Exception as e:
            print(f"Failed to copy {filename}: {e}")
            failed_files.append(filename)

print(f"\nSuccessfully copied {files_copied} new files.")
if failed_files:
    print(f"Failed to copy {len(failed_files)} files.")
