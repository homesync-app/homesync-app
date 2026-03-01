import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('lib directory not found');
    return;
  }

  final replacements = {
    'package:homesync_client/theme/': 'package:homesync_client/core/theme/',
    'package:homesync_client/utils/': 'package:homesync_client/core/utils/',
    'package:homesync_client/widgets/': 'package:homesync_client/shared/widgets/',
    'package:homesync_client/providers/core_providers.dart': 'package:homesync_client/core/providers/core_providers.dart',
    'package:homesync_client/providers/theme_provider.dart': 'package:homesync_client/core/providers/theme_provider.dart',
  };

  print('Starting migration...');
  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final file = entity;
      final originalContent = await file.readAsString();
      var content = originalContent;

      // 1. Package replacements
      for (final entry in replacements.entries) {
        content = content.replaceAll(entry.key, entry.value);
      }

      // 2. Relative imports -> Package imports
      // theme/
      content = content.replaceAllMapped(
          RegExp("import\\s+['\"].*?/theme/(.*?)['\"];"),
          (match) => "import 'package:homesync_client/core/theme/\${match.group(1)}';");
      
      // utils/
      content = content.replaceAllMapped(
          RegExp("import\\s+['\"].*?/utils/(.*?)['\"];"),
          (match) => "import 'package:homesync_client/core/utils/\${match.group(1)}';");
          
      // widgets/
      content = content.replaceAllMapped(
          RegExp("import\\s+['\"].*?/widgets/(.*?)['\"];"),
          (match) => "import 'package:homesync_client/shared/widgets/\${match.group(1)}';");

      // Providers core and theme
      content = content.replaceAllMapped(
          RegExp("import\\s+['\"].*?core_providers\\.dart['\"];"),
          (_) => "import 'package:homesync_client/core/providers/core_providers.dart';");
      content = content.replaceAllMapped(
          RegExp("import\\s+['\"].*?theme_provider\\.dart['\"];"),
          (_) => "import 'package:homesync_client/core/providers/theme_provider.dart';");

      // Category / member models
      content = content.replaceAllMapped(
          RegExp("import\\s+['\"].*?category_model\\.dart['\"];"),
          (_) => "import 'package:homesync_client/features/tasks/domain/models/category_model.dart';");
      content = content.replaceAllMapped(
          RegExp("import\\s+['\"].*?member\\.dart['\"];"),
          (_) => "import 'package:homesync_client/features/household/domain/models/member.dart';");

      // Providers task category / household
      content = content.replaceAllMapped(
          RegExp("import\\s+['\"].*?category_providers\\.dart['\"];"),
          (_) => "import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';");
      content = content.replaceAllMapped(
          RegExp("import\\s+['\"].*?household_providers\\.dart['\"];"),
          (_) => "import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';");

      if (content != originalContent) {
        await file.writeAsString(content);
        print('Updated: \${file.path}');
      }
    }
  }
  print('Migration completed.');
}
