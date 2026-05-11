import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

import 'expense_form_data.dart';

Future<void> showExpenseMemberSelectorSheet({
  required BuildContext context,
  required List<MemberModel> members,
  required ValueChanged<MemberModel> onSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.theme.scaffoldBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      final t = AppLocalizations.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.expensesFormFieldPayer,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...members.map(
                (member) => ListTile(
                  leading: CustomUserAvatar(
                    avatarUrl: member.avatarUrl,
                    name: member.displayName,
                    radius: 20,
                    forceCircular: true,
                  ),
                  title: Text(
                    member.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    onSelected(member);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showExpenseCategorySelectorSheet({
  required BuildContext context,
  required List<Map<String, dynamic>> categories,
  required Map<String, dynamic> selectedCategory,
  required ValueChanged<Map<String, dynamic>> onSelected,
  required bool isIncome,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: context.theme.scaffoldBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      final t = AppLocalizations.of(context);
      return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                t.expensesFormSelectCategoryTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory['id'] == category['id'];
                  final categoryId = category['id'] as String;
                  final categoryName = isIncome
                      ? localizedIncomeCategoryName(t, categoryId)
                      : localizedExpenseCategoryName(t, categoryId);
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (category['color'] as Color).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CategoryMapping.getCategoryMaterialIcon(categoryId),
                        size: 20,
                        color: category['color'] as Color,
                      ),
                    ),
                    title: Text(
                      categoryName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      onSelected(category);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

