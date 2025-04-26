import os
import re

source_dir = "../cfg/tf2ware_ultimate/"
target_dir = "../scripts/vscripts/tf2ware_ultimate/default/"
version_file = "../scripts/vscripts/tf2ware_ultimate/config.nut"

version_keys = {
    "minigames": "WARE_MINIGAME_VERSION",
    "bossgames": "WARE_BOSSGAME_VERSION",
    "specialrounds": "WARE_SPECIALROUND_VERSION",
    "themes": "WARE_THEME_VERSION"
}

versions = {}
version_pattern = re.compile(r'const\s+(\w+)\s+=\s+(\d+)')

with open(version_file, "r", encoding="utf-8") as vf:
    for line in vf:
        match = version_pattern.search(line)
        if match:
            versions[match.group(1)] = match.group(2)
            
print(versions)      

os.makedirs(target_dir, exist_ok=True)

for file_name in os.listdir(source_dir):
    if file_name.endswith(".cfg"):
        if file_name == "item_whitelist.cfg":
            continue
        
        source_path = os.path.join(source_dir, file_name)
        target_name = file_name.replace(".cfg", ".nut")
        target_path = os.path.join(target_dir, target_name)
        
        base_name = os.path.splitext(file_name)[0] # strip extension
        version_header = ""
        
        if base_name in version_keys:
            version_key = version_keys[base_name]
            if version_key in versions:
                version_header = f'VERSION {versions[version_key]}\n'
        
        with open(source_path, "r", encoding="utf-8") as source_file:
            contents = source_file.read()
        
        contents = contents.replace('"', '""')
        code = f'// auto-generated file, do not edit. edit the matching file in the "cfg" folder instead\nbuffer<-@"{version_header}{contents}"'
        
        with open(target_path, "w", newline='\n', encoding="utf-8") as target_file:
            target_file.write(code)
        
        print(f"Converted {file_name} to {os.path.basename(target_path)}")

os.system("pause")