import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart'
    show dashboardCategoryAccent, dashboardCategoryIcon;
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_detail_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

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
    final title = _displayTitle(
      _localizedActivityTitle(context, data),
      category,
    );
    final userName = (data['user_name'] as String?)?.trim();
    final avatarUrl =
        (data['avatar_url'] ?? data['creator_avatar_url']) as String?;
    final xpReward =
        _readInt(data['xp_reward'] ?? data['xp_per_user'] ?? data['xp']);
    final coinsReward = _readInt(
      data['coins_reward'] ?? data['coins_per_user'] ?? data['coins'],
    );
    final amount = _parseAmount(data['amount']);
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
    final accent = _activityAccent(
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
        onTap: () => _openDetail(context, ref, type, data),
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
                              _formatTime(createdAt),
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
                            label: '$coinsReward coins',
                            color: AppColors.sage,
                            icon: Icons.monetization_on_rounded,
                            theme: theme,
                          ),
                        if (isReward && _readInt(data['reward_cost']) != null)
                          _activityMetaPill(
                            label: '-${_readInt(data['reward_cost'])} coins',
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

  Future<void> _openDetail(
    BuildContext context,
    WidgetRef ref,
    String? type,
    Map<String, dynamic> data,
  ) async {
    if (type == 'task') {
      final taskData = <String, dynamic>{
        ...data,
        'title': data['task_title'] ?? data['title'],
        'category': data['category'] ?? 'limpieza',
        'xp_reward': data['xp_reward'] ?? data['xp_per_user'] ?? data['xp'],
        'coin_reward':
            data['coins_reward'] ?? data['coins_per_user'] ?? data['coins'],
        'completed_at': activity['created_at'],
        'activity_id': activity['id'],
        'completed_user': {
          'full_name': data['user_name'],
          'avatar_url': data['avatar_url'] ?? data['creator_avatar_url'],
          'id': activity['creator_id'],
        },
      };
      await TaskDetailSheet.show(context, taskData);
      return;
    }

    if (type == 'expense') {
      final expenseId = data['expense_id']?.toString();
      if (expenseId == null || expenseId.isEmpty) return;
      // Open instantly with the data the feed already shows — the sheet
      // enriches itself (splits, description) in place, so tapping an expense
      // feels as immediate as tapping a task instead of waiting on a network
      // round-trip with no feedback.
      final createdAt = DateTime.tryParse(
            activity['created_at'] as String? ?? '',
          )?.toLocal() ??
          DateTime.now();
      ExpenseDetailSheet.show(
        context,
        ExpenseModel(
          id: expenseId,
          title: data['title']?.toString() ?? '',
          titleKey: data['title_key']?.toString(),
          amount: _parseAmount(data['amount']) ?? 0,
          category: data['category'] as String?,
          householdId: activity['household_id']?.toString() ?? '',
          paidBy: activity['creator_id']?.toString() ?? '',
          paidAt: createdAt,
          createdAt: createdAt,
          payerFullName: data['user_name'] as String?,
          payerAvatarUrl:
              (data['avatar_url'] ?? data['creator_avatar_url']) as String?,
        ),
      );
    }
  }

  Color _activityAccent(
    BuildContext context,
    String? type,
    String? category, {
    Color? resolvedCategoryColor,
  }) {
    if (type == 'expense') return const Color(0xFFF08B49);
    if (type == 'reward') return AppColors.accentGold;
    if (resolvedCategoryColor != null) return resolvedCategoryColor;
    return dashboardCategoryAccent(context, category);
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
        _activityIcon(type, category),
        size: 18,
        color: accent,
      ),
    );
  }

  IconData _activityIcon(String? type, String? category) {
    switch (type) {
      case 'expense':
        return Icons.receipt_long_rounded;
      case 'reward':
        return Icons.card_giftcard_rounded;
      case 'task':
        return dashboardCategoryIcon(category);
      default:
        return dashboardCategoryIcon(category);
    }
  }

  int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  double? _parseAmount(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  String _normalizedText(String raw) {
    return raw
        .replaceAll('Complet\u00c3\u00b3 la tarea:', '')
        .replaceAll('Agreg\u00c3\u00b3 un gasto:', '')
        .replaceAll('Canje\u00c3\u00b3 un premio:', '')
        .replaceAll('\u00c3\u00b3', 'ó')
        .replaceAll('\u00c3\u00a1', 'á')
        .replaceAll('\u00c3\u00a9', 'é')
        .replaceAll('\u00c3\u00ad', 'í')
        .replaceAll('\u00c3\u00ba', 'ú')
        .replaceAll('\u00c3\u00b1', 'ñ')
        .replaceAll('\u00c2\u00bf', '¿')
        .replaceAll('\u00c2\u00a1', '¡')
        .replaceAll('  ', ' ')
        .trim();
  }

  String _displayTitle(Object? rawTitle, String? category) {
    final normalized = _normalizedText('${rawTitle ?? ''}');
    if (normalized.isEmpty) return 'Actividad';

    final lower = normalized.toLowerCase();
    final categoryLower = category?.trim().toLowerCase();
    if (lower == categoryLower ||
        CategoryMapping.categoryNames.containsKey(lower)) {
      return CategoryMapping.displayName(normalized);
    }
    return normalized;
  }

  String _formatCurrency(WidgetRef ref, double amount) {
    return ref.read(currencyProvider).format(amount);
  }

  String _localizedActivityTitle(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final fallback = data['task_title'] ??
        data['title'] ??
        data['description'] ??
        'Actividad';
    return localizedTaskCatalogText(
      AppLocalizations.of(context),
      data['title_key'] as String?,
      fallback.toString(),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return DateFormat('d MMM', 'es_AR').format(time);
  }
}
