import 'dart:io';

void main() async {
  final libDir = Directory('lib/features');

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      if (!content.contains(r'${match.group(1)}')) continue;

      var newContent = content;

      // Because there are only a few possible files from /theme, /utils, /widgets,
      // and we cannot guess the original properly, but I can look at the Class usage!
      // Since it's easier, let's just make a very smart regex or just hardcode for our case.
      // Usually, if it contains 'AppColors' or 'AppTheme', we need theme.
      if (newContent.contains('AppColors')) {
        newContent = newContent.replaceAll(
          "import 'package:homesync_client/core/theme/\${match.group(1)}';", 
          "import 'package:homesync_client/theme/app_colors.dart';"
        );
      }
      if (newContent.contains('AppTheme')) {
        newContent = newContent.replaceAll(
          "import 'package:homesync_client/core/theme/\${match.group(1)}';", 
          "import 'package:homesync_client/theme/app_theme.dart';"
        );
      }

      // Utils
      if (newContent.contains('AppAnimations')) {
        newContent = newContent.replaceAll(
          "import 'package:homesync_client/core/utils/\${match.group(1)}';", 
          "import 'package:homesync_client/utils/app_animations.dart';"
        );
      }

      // Widgets 
      // There are 13 widgets.
      final widgetMapping = {
        'UserAvatar': 'user_avatar.dart',
        'BalanceCard': 'balance_card.dart',
        'ScheduleDialog': 'schedule_dialog.dart',
        'FaceoffWidget': 'faceoff_widget.dart',
        'CustomBottomNav': 'custom_bottom_nav.dart',
        'MercadopagoSettingsCard': 'mercadopago_settings_card.dart',
        'AvatarPickerSheet': 'avatar_picker_sheet.dart',
        
        'TaskCard': 'task_card.dart',
        'CreateTaskDialog': 'create_task_dialog.dart',
        'CompleteTaskSheet': 'complete_task_sheet.dart',
        'EditTaskSheet': 'edit_task_sheet.dart',
        'TaskDetailSheet': 'task_detail_sheet.dart',
        'AddTaskOptionsSheet': 'add_task_options_sheet.dart',
        'ExpenseFormSheet': 'expense_form_sheet.dart',
      };

      for (final entry in widgetMapping.entries) {
        if (newContent.contains(entry.key)) {
          // Replace only ONE instance at a time to not overwrite other widget imports wrongly
          newContent = newContent.replaceFirst(
            "import 'package:homesync_client/shared/widgets/\${match.group(1)}';", 
            "import 'package:homesync_client/widgets/\${entry.value}';"
          );
        }
      }

      // Fallback for duplicates or missed 
      newContent = newContent.replaceAll("import 'package:homesync_client/core/theme/\${match.group(1)}';", "");
      newContent = newContent.replaceAll("import 'package:homesync_client/core/utils/\${match.group(1)}';", "");
      newContent = newContent.replaceAll("import 'package:homesync_client/shared/widgets/\${match.group(1)}';", "");

      // Provider replacements that we shouldn't have changed 
      newContent = newContent.replaceAll("import 'package:homesync_client/core/providers/core_providers.dart';", "import 'package:homesync_client/providers/core_providers.dart';");
      newContent = newContent.replaceAll("import 'package:homesync_client/core/providers/theme_provider.dart';", "import 'package:homesync_client/providers/theme_provider.dart';");
      
      newContent = newContent.replaceAll("import 'package:homesync_client/features/tasks/domain/models/category_model.dart';", "import 'package:homesync_client/models/category_model.dart';");
      newContent = newContent.replaceAll("import 'package:homesync_client/features/household/domain/models/member.dart';", "import 'package:homesync_client/models/member.dart';");
      newContent = newContent.replaceAll("import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';", "import 'package:homesync_client/providers/category_providers.dart';");
      newContent = newContent.replaceAll("import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';", "import 'package:homesync_client/providers/household_providers.dart';");


      await entity.writeAsString(newContent);
      print('Fixed: \${entity.path}');
    }
  }
}
