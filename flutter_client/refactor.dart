import 'dart:io';

void main() {
  final dir = Directory('lib');
  final replacers = {
    'AppColors.surface': 'context.theme.surface',
    'AppColors.surfaceVariant': 'context.theme.surfaceVariant',
    'AppColors.background': 'context.theme.background',
    'AppColors.textPrimary': 'context.theme.textPrimary',
    'AppColors.textSecondary': 'context.theme.textSecondary',
    'AppColors.textMuted': 'context.theme.textMuted',
    'AppColors.border': 'context.theme.border',
    'AppColors.cardBorder': 'context.theme.cardBorder',
    'AppColors.inputBorder': 'context.theme.inputBorder',
    'AppColors.shadow': 'context.theme.shadow',
    'AppColors.glassWhite': 'context.theme.glassWhite',
    'AppColors.glassBorder': 'context.theme.glassBorder',
  };

  int count = 0;
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.endsWith('app_colors.dart') &&
        !entity.path.endsWith('app_theme.dart') &&
        !entity.path.endsWith('app_theme_extension.dart') &&
        !entity.path.endsWith('refactor.dart')) {
      var content = entity.readAsStringSync();
      var originalContent = content;

      if (!content.contains('AppColors.')) continue;

      replacers.forEach((k, v) {
        content = content.replaceAll(k, v);
      });

      if (content != originalContent) {
        final lines = content.split('\n');
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].contains('context.theme.')) {
            lines[i] = lines[i].replaceAll('const ', '');
            lines[i] = lines[i].replaceAll('const\t', '');
          }
        }
        content = lines.join('\n');

        if (!content.contains('app_theme_extension.dart')) {
          content =
              "import 'package:homesync_client/theme/app_theme_extension.dart';\n$content";
        }

        entity.writeAsStringSync(content);
        count++;
      }
    }
  }
  print('Updated \$count files');
}
