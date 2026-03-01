import os, glob
import re

lib_dir = 'lib'
replacements = {
    r'package:homesync_client/theme/': r'package:homesync_client/core/theme/',
    r'package:homesync_client/utils/': r'package:homesync_client/core/utils/',
    r'package:homesync_client/widgets/': r'package:homesync_client/shared/widgets/',
    r'package:homesync_client/providers/core_providers.dart': r'package:homesync_client/core/providers/core_providers.dart',
    r'package:homesync_client/providers/theme_provider.dart': r'package:homesync_client/core/providers/theme_provider.dart',
}

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            original = content
            # Package imports
            for old, new in replacements.items():
                content = re.sub(old, new, content)
            
            # Relative imports -> Package imports
            # theme/ -> core/theme/
            content = re.sub(r'import\s+[\'\"].*?/theme/(.*?)[\'\"];', r"import 'package:homesync_client/core/theme/\1';", content)
            
            # utils/ -> core/utils/
            content = re.sub(r'import\s+[\'\"].*?/utils/(.*?)[\'\"];', r"import 'package:homesync_client/core/utils/\1';", content)
            
            # widgets/ -> shared/widgets/
            content = re.sub(r'import\s+[\'\"].*?/widgets/(.*?)[\'\"];', r"import 'package:homesync_client/shared/widgets/\1';", content)
            
            # Providers
            content = re.sub(r'import\s+[\'\"].*?core_providers\.dart[\'\"];', r"import 'package:homesync_client/core/providers/core_providers.dart';", content)
            content = re.sub(r'import\s+[\'\"].*?theme_provider\.dart[\'\"];', r"import 'package:homesync_client/core/providers/theme_provider.dart';", content)

            # models/category_model.dart -> features/tasks/domain/models/category_model.dart
            content = re.sub(r'import\s+[\'\"].*?category_model\.dart[\'\"];', r"import 'package:homesync_client/features/tasks/domain/models/category_model.dart';", content)
            # models/member.dart -> features/household/domain/models/member.dart
            content = re.sub(r'import\s+[\'\"].*?member\.dart[\'\"];', r"import 'package:homesync_client/features/household/domain/models/member.dart';", content)
            
            # category_providers.dart -> features/tasks/presentation/providers/category_providers.dart
            content = re.sub(r'import\s+[\'\"].*?category_providers\.dart[\'\"];', r"import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';", content)
            
            # household_providers.dart -> features/household/presentation/providers/household_providers.dart
            content = re.sub(r'import\s+[\'\"].*?household_providers\.dart[\'\"];', r"import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';", content)

            if content != original:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f'Updated {filepath}')

