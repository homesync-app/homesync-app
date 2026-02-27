import 'dart:io';

void main() {
  final dir = Directory('lib');
  final replacers = {
    'context.theme.surface': 'AppColors.surface',
    'context.theme.surfaceVariant': 'AppColors.surfaceVariant',
    'context.theme.background': 'AppColors.background',
    'context.theme.textPrimary': 'AppColors.textPrimary',
    'context.theme.textSecondary': 'AppColors.textSecondary',
    'context.theme.textMuted': 'AppColors.textMuted',
    'context.theme.border': 'AppColors.border',
    'context.theme.cardBorder': 'AppColors.cardBorder',
    'context.theme.inputBorder': 'AppColors.inputBorder',
    'context.theme.shadow': 'AppColors.shadow',
    'context.theme.glassWhite': 'AppColors.glassWhite',
    'context.theme.glassBorder': 'AppColors.glassBorder',
  };

  int count = 0;
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.endsWith('refactor.dart')) {
      var content = entity.readAsStringSync();
      var originalContent = content;

      if (!content.contains('context.theme.')) continue;

      replacers.forEach((k, v) {
        content = content.replaceAll(k, v);
      });

      if (content != originalContent) {
        // Remove the import I added
        content = content.replaceAll(
            "import 'package:homesync_client/theme/app_theme_extension.dart';\n",
            '');

        entity.writeAsStringSync(content);
        count++;
      }
    }
  }
  print('Reverted \$count files');
}
