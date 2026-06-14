import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_presentation.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';

/// Full-width timeline row for the solo home activity feed.
///
/// Solo replaces the chat-bubble feed (a conversation metaphor that needs two
/// people) with classic movement rows: category icon, title, relative time,
/// and the key figure (amount / XP / coins) on the trailing edge. No avatar —
/// in solo every entry is the user's own — and no "household" type label.
class SoloActivityTile extends ConsumerWidget {
  final Map<String, dynamic> activity;

  const SoloActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);

    final type = activity['type'] as String?;
    final data = (activity['data'] as Map<String, dynamic>?) ?? {};
    final isReward = type == 'reward';

    final createdAt =
        DateTime.tryParse(activity['created_at'] as String? ?? '')?.toLocal() ??
            DateTime.now();
    final category = data['category'] as String?;
    final title = activityDisplayTitle(
      localizedActivityTitle(t, data),
      category,
    );
    final xpReward = activityReadInt(
      data['xp_reward'] ?? data['xp_per_user'] ?? data['xp'],
    );
    final coinsReward = activityReadInt(
      data['coins_reward'] ?? data['coins_per_user'] ?? data['coins'],
    );
    final amount = activityParseAmount(data['amount']);
    final rewardCost = activityReadInt(data['reward_cost']);

    final normalizedCategory = CategoryMapping.normaliseCategory(category);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryData = categoriesAsync.maybeWhen(
      data: (list) {
        for (final item in list) {
          if (CategoryMapping.normaliseCategory(item.id) ==
              normalizedCategory) {
            return item;
          }
        }
        return null;
      },
      orElse: () => null,
    );
    final rewardAccent =
        theme.isDarkMode ? AppColors.accentGold : const Color(0xFFC47A18);
    final accent = isReward
        ? rewardAccent
        : activityAccent(
            context,
            type,
            category,
            resolvedCategoryColor: categoryData != null
                ? AppColors.fromHex(categoryData.color)
                : null,
          );

    // Trailing figures, most relevant first; two lines max keeps the row calm.
    final figures = <_TrailingFigure>[
      if (amount != null && amount > 0)
        _TrailingFigure(currency.format(amount), theme.textPrimary),
      if (xpReward != null && xpReward > 0)
        _TrailingFigure('+$xpReward XP', const Color(0xFFE8943A)),
      if (coinsReward != null && coinsReward > 0)
        _TrailingFigure(t.activityCoinsPlus(coinsReward), AppColors.sage),
      if (isReward && rewardCost != null)
        _TrailingFigure(t.activityCoinsMinus(rewardCost), rewardAccent),
    ].take(2).toList();

    return Semantics(
      button: true,
      child: AnimatedPress(
        onTap: () => openActivityDetail(context, ref, activity),
        scale: 0.985,
        haptic: AppPressHaptic.selection,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: theme.border.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(
                  activityIcon(type, category),
                  size: 20,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textPrimary.withValues(alpha: 0.92),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatActivityTimeAgo(createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (figures.isNotEmpty) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < figures.length; i++) ...[
                      if (i > 0) const SizedBox(height: 3),
                      Text(
                        figures[i].label,
                        style: TextStyle(
                          color: figures[i].color,
                          fontSize: i == 0 ? 13.5 : 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ).tabular,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailingFigure {
  final String label;
  final Color color;

  const _TrailingFigure(this.label, this.color);
}
