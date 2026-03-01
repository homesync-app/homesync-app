import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  final testDir = Directory('test');

  final replacements = {
    // Package paths
    'package:homesync_client/theme/': 'package:homesync_client/core/theme/',
    'package:homesync_client/utils/': 'package:homesync_client/core/utils/',
    'package:homesync_client/providers/core_providers.dart': 'package:homesync_client/core/providers/core_providers.dart',
    'package:homesync_client/providers/theme_provider.dart': 'package:homesync_client/core/providers/theme_provider.dart',
    'package:homesync_client/providers/household_providers.dart': 'package:homesync_client/features/household/presentation/providers/household_providers.dart',
    'package:homesync_client/models/member.dart': 'package:homesync_client/features/household/domain/models/member.dart',
    'package:homesync_client/models/category_model.dart': 'package:homesync_client/features/tasks/domain/models/category_model.dart',
    'package:homesync_client/providers/category_providers.dart': 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart',
    'package:homesync_client/models/expense.dart': 'package:homesync_client/features/expenses/domain/models/expense_model.dart',
    'package:homesync_client/providers/expense_providers.dart': 'package:homesync_client/features/expenses/presentation/providers/expense_providers.dart',
    'package:homesync_client/models/savings_goal.dart': 'package:homesync_client/features/savings/domain/models/savings_model.dart',
    'package:homesync_client/providers/savings_providers.dart': 'package:homesync_client/features/savings/presentation/providers/savings_providers.dart',
    'package:homesync_client/providers/shopping_providers.dart': 'package:homesync_client/features/shopping/presentation/providers/shopping_providers.dart',
    'package:homesync_client/providers/reward_providers.dart': 'package:homesync_client/features/rewards/presentation/providers/rewards_provider.dart',
    'package:homesync_client/providers/task_providers.dart': 'package:homesync_client/features/tasks/presentation/providers/task_providers.dart',
    'package:homesync_client/models/task.dart': 'package:homesync_client/features/tasks/domain/models/task_model.dart',
    'package:homesync_client/screens/home_screen.dart': 'package:homesync_client/features/dashboard/presentation/screens/home_screen.dart',
    'package:homesync_client/screens/login_screen.dart': 'package:homesync_client/features/auth/presentation/screens/login_screen.dart',
    'package:homesync_client/screens/setup_screen.dart': 'package:homesync_client/features/household/presentation/screens/setup_screen.dart',
    'package:homesync_client/screens/settings_screen.dart': 'package:homesync_client/features/settings/presentation/screens/settings_screen.dart',
    'package:homesync_client/screens/notifications_screen.dart': 'package:homesync_client/features/notifications/presentation/screens/notifications_screen.dart',
    'package:homesync_client/screens/stats_screen.dart': 'package:homesync_client/features/stats/presentation/screens/stats_screen.dart',
    'package:homesync_client/screens/weekly_winner_screen.dart': 'package:homesync_client/features/tasks/presentation/screens/weekly_winner_screen.dart',
    'package:homesync_client/screens/calendar_screen.dart': 'package:homesync_client/features/tasks/presentation/screens/calendar_screen.dart',
    'package:homesync_client/screens/onboarding_screen.dart': 'package:homesync_client/features/auth/presentation/screens/onboarding_screen.dart',
    'package:homesync_client/screens/members_screen.dart': 'package:homesync_client/features/household/presentation/screens/members_screen.dart',
    'package:homesync_client/screens/tasks_screen.dart': 'package:homesync_client/features/tasks/presentation/screens/tasks_screen.dart',
    'package:homesync_client/screens/expenses_screen.dart': 'package:homesync_client/features/expenses/presentation/screens/expenses_screen.dart',
    'package:homesync_client/screens/rewards_screen.dart': 'package:homesync_client/features/rewards/presentation/screens/rewards_screen.dart',
    'package:homesync_client/screens/shopping_list_screen.dart': 'package:homesync_client/features/shopping/presentation/screens/shopping_list_screen.dart',
    // Relative imports (common patterns in migrated files)
    "import '../theme/": "import 'package:homesync_client/core/theme/",
    "import '../utils/": "import 'package:homesync_client/core/utils/",
    "import '../providers/core_providers.dart'": "import 'package:homesync_client/core/providers/core_providers.dart'",
    "import '../providers/theme_provider.dart'": "import 'package:homesync_client/core/providers/theme_provider.dart'",
    "import '../widgets/": "import 'package:homesync_client/shared/widgets/",
    "import '../services/": "import 'package:homesync_client/core/services/",
    "import '../repositories/expense_repository.dart'": "import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart'",
    "import '../repositories/shopping_repository.dart'": "import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart'",
    "import '../repositories/savings_repository.dart'": "import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart'",
    "import '../providers/task_providers.dart'": "import 'package:homesync_client/features/tasks/presentation/providers/task_providers.dart'",
    "import '../providers/expense_providers.dart'": "import 'package:homesync_client/features/expenses/presentation/providers/expense_providers.dart'",
    "import '../providers/shopping_providers.dart'": "import 'package:homesync_client/features/shopping/presentation/providers/shopping_providers.dart'",
    "import '../providers/savings_providers.dart'": "import 'package:homesync_client/features/savings/presentation/providers/savings_providers.dart'",
    "import '../providers/reward_providers.dart'": "import 'package:homesync_client/features/rewards/presentation/providers/rewards_provider.dart'",
    "import '../providers/category_providers.dart'": "import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart'",
    "import '../models/category_model.dart'": "import 'package:homesync_client/features/tasks/domain/models/category_model.dart'",
    "import '../models/expense.dart'": "import 'package:homesync_client/features/expenses/domain/models/expense_model.dart'",
    "import '../models/task.dart'": "import 'package:homesync_client/features/tasks/domain/models/task_model.dart'",
    "import '../models/member.dart'": "import 'package:homesync_client/features/household/domain/models/member.dart'",
  };

  final wordReplacements = {
    'Member': 'MemberModel',
    'SavingsGoal': 'SavingsGoalModel',
    'SavingsContribution': 'SavingsContributionModel',
    'ShoppingItem': 'ShoppingItemModel',
    'Expense': 'ExpenseModel',
    'HouseholdBalance': 'HouseholdBalanceModel',
  };

  int count = 0;

  Future<void> processDir(Directory dir) async {
    if (!await dir.exists()) return;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        var newContent = content;
        for (final entry in replacements.entries) {
          newContent = newContent.replaceAll(entry.key, entry.value);
        }

        // Whole word replacements for classes
        for (final entry in wordReplacements.entries) {
          final regex = RegExp('\\b${entry.key}\\b');
          newContent = newContent.replaceAll(regex, entry.value);
        }

        if (newContent != content) {
          await entity.writeAsString(newContent);
          count++;
          print('Updated: ${entity.path}');
        }
      }
    }
  }

  await processDir(libDir);
  await processDir(testDir);

  print('Total files updated: $count');
}
