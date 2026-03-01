import 'dart:io';

void main() async {
  final libDir = Directory('lib');

  final widgetMapping = {
    'UserAvatar': 'user_avatar.dart',
    'CustomUserAvatar': 'user_avatar.dart',
    'BalanceCard': 'balance_card.dart',
    'FaceoffWidget': 'faceoff_widget.dart',
    'CustomBottomNav': 'custom_bottom_nav.dart',
    'ScheduleDialog': 'schedule_dialog.dart',
    'AvatarPickerSheet': 'avatar_picker_sheet.dart',
    
    'TaskCard': 'task_card.dart',
    'CreateTaskDialog': 'create_task_dialog.dart',
    'CompleteTaskSheet': 'complete_task_sheet.dart',
    'EditTaskSheet': 'edit_task_sheet.dart',
    'TaskDetailSheet': 'task_detail_sheet.dart',
    'AddTaskOptionsSheet': 'add_task_options_sheet.dart',
    'ExpenseFormSheet': 'expense_form_sheet.dart',
  };

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      if (!content.contains(r'${entry.value}') && !content.contains(r'${match.group(1)}')) continue;

      var newContent = content;

      // Fix theme/utils first
      newContent = newContent.replaceAll(
          "import 'package:homesync_client/core/theme/\${match.group(1)}';", 
          "import 'package:homesync_client/theme/app_colors.dart';"
      );
      newContent = newContent.replaceAll(
          "import 'package:homesync_client/core/utils/\${match.group(1)}';", 
          "import 'package:homesync_client/utils/app_animations.dart';"
      );

      // Fix widgets
      for (final widgetName in widgetMapping.keys) {
        if (newContent.contains(widgetName)) {
           newContent = newContent.replaceFirst(
             "import 'package:homesync_client/widgets/\${entry.value}';", 
             "import 'package:homesync_client/widgets/\${widgetMapping[widgetName]}';"
           );
        }
      }
      
      // Secondary pass for remaining widgets if any (e.g. shared/widgets)
      newContent = newContent.replaceAll(
          "import 'package:homesync_client/shared/widgets/\${match.group(1)}';", 
          "import 'package:homesync_client/widgets/user_avatar.dart';" // Most likely candidate
      );

      // Clean up the template if it still exists
      newContent = newContent.replaceAll("import 'package:homesync_client/widgets/\${entry.value}';", "");

      await entity.writeAsString(newContent);
      print('Fixed: \${entity.path}');
    }
  }
}
