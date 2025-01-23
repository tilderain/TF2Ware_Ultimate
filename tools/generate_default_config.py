import os

source_dir = "../cfg/tf2ware_ultimate/"
target_dir = "../scripts/vscripts/tf2ware_ultimate/default/"

os.makedirs(target_dir, exist_ok=True)

for file_name in os.listdir(source_dir):
    if file_name.endswith(".cfg"):
        if file_name == "item_whitelist.cfg":
            continue
        source_path = os.path.join(source_dir, file_name)
        target_path = os.path.join(target_dir, file_name.replace(".cfg", ".nut"))

        with open(source_path, "r", encoding="utf-8") as source_file:
            contents = source_file.read()
                        
        contents = contents.replace('"', '""')
        code = f'// auto-generated file, do not edit. edit the matching file in the "cfg" folder instead\nbuffer<-@"{contents}"'

        with open(target_path, "w", newline='\n', encoding="utf-8") as target_file:
            target_file.write(code)

        print(f"Converted {file_name} to {os.path.basename(target_path)}")