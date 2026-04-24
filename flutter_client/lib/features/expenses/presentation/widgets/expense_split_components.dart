import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class ExpenseSplitModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ExpenseSplitModeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) onTap();
      },
      side: BorderSide(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.22)
            : theme.border.withValues(alpha: 0.78),
        width: 1.15,
      ),
      showCheckmark: false,
      avatar: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : theme.elevatedSurface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 15,
          color: isSelected ? AppColors.primary : theme.textSecondary,
        ),
      ),
      backgroundColor: theme.surface,
      selectedColor: theme.primary.withValues(alpha: 0.08),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : theme.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: const StadiumBorder(),
    );
  }
}

class ExpenseEqualSplitSelection extends StatelessWidget {
  final List<MemberModel> members;
  final Set<String> selectedMembers;
  final ValueChanged<String> onToggle;

  const ExpenseEqualSplitSelection({
    super.key,
    required this.members,
    required this.selectedMembers,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: members.map((member) {
        final isSelected = selectedMembers.contains(member.userId);
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onToggle(member.userId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.24)
                    : AppColors.divider.withValues(alpha: 0.9),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomUserAvatar(
                  avatarUrl: member.avatarUrl,
                  name: member.displayName,
                  radius: 14,
                  forceCircular: true,
                ),
                const SizedBox(width: 10),
                Text(
                  member.displayName,
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ExpenseFixedSplitRow extends StatelessWidget {
  final MemberModel member;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const ExpenseFixedSplitRow({
    super.key,
    required this.member,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.border.withValues(alpha: 0.82)),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          CustomUserAvatar(
            avatarUrl: member.avatarUrl,
            name: member.displayName,
            radius: 16,
            forceCircular: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.displayName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
          ),
          Text(
            '\$',
            style: TextStyle(
              color: theme.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 132,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.elevatedSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border.withValues(alpha: 0.7)),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                hintText: '0',
                hintStyle: TextStyle(color: theme.textMuted),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
