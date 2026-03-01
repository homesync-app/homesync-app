import os, glob
import re

lib_dir = 'lib'
replacements = {
    r'package:homesync_client/theme/': r'package:homesync_client/core/theme/',
    r'package:homesync_client/utils/': r'package:homesync_client/core/utils/',
    r'package:homesync_client/providers/core_providers.dart': r'package:homesync_client/core/providers/core_providers.dart',
    r'package:homesync_client/providers/theme_provider.dart': r'package:homesync_client/core/providers/theme_provider.dart',
    r'package:homesync_client/models/member.dart': r'package:homesync_client/features/household/domain/models/member.dart',
    r'package:homesync_client/providers/household_providers.dart': r'package:homesync_client/features/household/presentation/providers/household_providers.dart',
    r'package:homesync_client/models/category_model.dart': r'package:homesync_client/features/tasks/domain/models/category_model.dart',
    r'package:homesync_client/providers/category_providers.dart': r'package:homesync_client/features/tasks/presentation/providers/category_providers.dart',
}

files = glob.glob(os.path.join(lib_dir, '**', '*.dart'), recursive=True)
files.extend(glob.glob(os.path.join('test', '**', '*.dart'), recursive=True))

count = 0
for file_path in files:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for old, new in replacements.items():
        new_content = new_content.replace(old, new)
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        count += 1
        print(f"Updated: {file_path}")

print(f"Total files updated: {count}")
