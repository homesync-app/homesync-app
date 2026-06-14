import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_presentation.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class ActivityChatBubble extends ConsumerWidget {
  final Map<String, dynamic> activity;
  final String? currentUserId;

  const ActivityChatBubble({
    super.key,
    required this.activity,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final type = activity['type'] as String?;
    final data = (activity['data'] as Map<String, dynamic>?) ?? {};
    final creatorId = activity['creator_id'] as String?;
    final isMe = creatorId == currentUserId;
    final isReward = type == 'reward';

    final createdAt =
        DateTime.tryParse(activity['created_at'] as String? ?? '')?.toLocal() ??
            DateTime.now();

    final category = data['category'] as String?;
    final title = activityDisplayTitle(
      localizedActivityTitle(AppLocalizations.of(context), data),
      category,
    );
    final userName = (data['user_name'] as String?)?.trim();
    final avatarUrl =
        (data['avatar_url'] ?? data['creator_avatar_url']) as String?;
    final xpReward = activityReadInt(
      data['xp_reward'] ?? data['xp_per_user'] ?? data['xp'],
    );
    final coinsReward = activityReadInt(
      data['coins_reward'] ?? data['coins_per_user'] ?? data['coins'],
    );
    final amount = activityParseAmount(data['amount']);
    final normalizedCategory = CategoryMapping.normaliseCategory(category);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryData = categoriesAsync.maybeWhen(
      data: (list) {
        for (final category in list) {
          if (CategoryMapping.normaliseCategory(category.id) ==
              normalizedCategory) {
            return category;
          }
        }
        return null;
      },
      orElse: () => null,
    );
    final accent = activityAccent(
      context,
      type,
      category,
      resolvedCategoryColor:
          categoryData != null ? AppColors.fromHex(categoryData.color) : null,
    );
    final rewardSurface = theme.isDarkMode
        ? AppColors.accentGold.withValues(alpha: 0.12)
        : const Color(0xFFFFF4DD);
    final rewardAccent =
        theme.isDarkMode ? AppColors.accentGold : const Color(0xFFC47A18);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => openActivityDetail(context, ref, activity),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe) ...[
              CustomUserAvatar(
                name: userName,
                avatarUrl: avatarUrl,
                radius: 16,
                forceCircular: true,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Container(
                constraints: const BoxConstraints(minHeight: 84),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isReward
                      ? rewardSurface
                      : isMe
                          ? theme.elevatedSurface
                          : theme.surfaceVariant.withValues(
                              alpha: theme.isDarkMode ? 0.72 : 0.92,
                            ),
                  border: Border.all(
                    color: isReward
                        ? rewardAccent.withValues(alpha: 0.22)
                        : isMe
                            ? theme.primary.withValues(alpha: 0.1)
                            : theme.divider.withValues(alpha: 0.09),
                    width: 0.9,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadii.lg),
                    topRight: const Radius.circular(AppRadii.lg),
                    bottomLeft: Radius.circular(isMe ? 20 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isReward
                              ? rewardAccent
                              : isMe
                                  ? theme.primary
                                  : Colors.black)
                          .withValues(
                        alpha: isReward
                            ? 0.08
                            : isMe
                                ? 0.03
                                : 0.022,
                      ),
                      blurRadius: isReward ? 18 : 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (amount != null &&
                        ((xpReward ?? 0) == 0) &&
                        ((coinsReward ?? 0) == 0))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Gasto del hogar',
                          style: TextStyle(
                            color: accent.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    if (isReward)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Premio canjeado',
                          style: TextStyle(
                            color: rewardAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1.5),
                          child: _activityLeading(
                            type,
                            category,
                            isReward ? rewardAccent : accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textPrimary.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: theme.textMuted.withValues(alpha: 0.72),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatActivityTimeAgo(createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: theme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        if (amount != null)
                          _activityMetaPill(
                            label: _formatCurrency(ref, amount),
                            color: accent,
                            icon: Icons.payments_rounded,
                            theme: theme,
                          ),
                        if (xpReward != null && xpReward > 0)
                          _activityMetaPill(
                            label: '$xpReward XP',
                            color: const Color(0xFFE8943A),
                            icon: Icons.star_rounded,
                            theme: theme,
                          ),
                        if (coinsReward != null && coinsReward > 0)
                          _activityMetaPill(
                            label: AppLocalizations.of(context)
                                .activityCoinsPlus(coinsReward),
                            color: AppColors.sage,
                            icon: Icons.monetization_on_rounded,
                            theme: theme,
                          ),
                        if (isReward &&
                            activityReadInt(data['reward_cost']) != null)
                          _activityMetaPill(
                            label: AppLocalizations.of(context)
                                .activityCoinsMinus(
                              activityReadInt(data['reward_cost'])!,
                            ),
                            color: rewardAccent,
                            icon: Icons.monetization_on_rounded,
                            theme: theme,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 4),
              CustomUserAvatar(
                name: userName,
                avatarUrl: avatarUrl,
                radius: 16,
                forceCircular: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _activityMetaPill({
    required String label,
    required Color color,
    required IconData icon,
    required AppThemeColors theme,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.5, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Leading visual for redeemed rewards stays generic so the feed keeps a
  /// consistent rhythm even when reward catalog items use playful emoji.
  Widget _activityLeading(
    String? type,
    String? category,
    Color accent,
  ) {
    if (type == 'reward') {
      return Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.xs),
        ),
        child: Icon(Icons.card_giftcard_rounded, size: 15, color: accent),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Icon(
        activityIcon(type, category),
        size: 18,
        color: accent,
      ),
    );
  }

  String _formatCurrency(WidgetRef ref, double amount) {
    return ref.read(currencyProvider).format(amount);
  }
}
