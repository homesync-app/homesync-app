import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart'
    show dashboardCategoryAccent, dashboardCategoryIcon;
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_detail_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class FamilyActivityFeedItem extends ConsumerWidget {
  final Map<String, dynamic> activity;

  const FamilyActivityFeedItem({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final type = activity['type'] as String?;
    final data = (activity['data'] as Map<String, dynamic>?) ?? {};
    final createdAt =
        DateTime.tryParse(activity['created_at'] as String? ?? '')?.toLocal() ??
            DateTime.now();

    final userName = _firstName((data['user_name'] as String?)?.trim());
    final avatarUrl =
        (data['avatar_url'] ?? data['creator_avatar_url']) as String?;
    final detailTitle = _normalizedText(
      data['task_title'] ?? data['title'] ?? data['description'] ?? 'Actividad',
    );
    final amount = _parseAmount(data['amount']);
    final xpReward =
        _readInt(data['xp_reward'] ?? data['xp_per_user'] ?? data['xp']);
    final coinsReward = _readInt(
      data['coins_reward'] ?? data['coins_per_user'] ?? data['coins'],
    );
    final category = data['category'] as String?;
    final accent = _activityAccent(context, type, category);

    return InkWell(
      onTap: () => _openDetail(context, ref, type, data),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.divider.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomUserAvatar(
              name: userName,
              avatarUrl: avatarUrl,
              radius: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _headlineFor(type, userName),
                              style: TextStyle(
                                color: theme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.05,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              detailTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          _activityIcon(type, category),
                          size: 16,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _metaPill(
                        theme: theme,
                        color: theme.textMuted,
                        icon: Icons.access_time_rounded,
                        label: _formatTime(createdAt),
                      ),
                      if (amount != null)
                        _metaPill(
                          theme: theme,
                          color: accent,
                          icon: Icons.payments_rounded,
                          label: _formatCurrency(amount),
                        ),
                      if (xpReward != null && xpReward > 0)
                        _metaPill(
                          theme: theme,
                          color: const Color(0xFFE8943A),
                          icon: Icons.star_rounded,
                          label: '+$xpReward XP',
                        ),
                      if (coinsReward != null && coinsReward > 0)
                        _metaPill(
                          theme: theme,
                          color: AppColors.sage,
                          icon: Icons.monetization_on_rounded,
                          label: '+$coinsReward coins',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaPill({
    required AppThemeColors theme,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
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
      final repo = ref.read(expenseRepositoryProvider);
      final result = await repo.getExpenseWithSplits(expenseId);
      result.fold(
        (_) {},
        (fullData) => ExpenseDetailSheet.show(
          context,
          ExpenseModel.fromJson(fullData),
        ),
      );
    }
  }

  String _headlineFor(String? type, String userName) {
    switch (type) {
      case 'task':
        return '$userName completó';
      case 'expense':
        return '$userName registró un gasto';
      default:
        return '$userName hizo una acción';
    }
  }

  Color _activityAccent(BuildContext context, String? type, String? category) {
    if (type == 'expense') return const Color(0xFFF08B49);
    return dashboardCategoryAccent(context, category);
  }

  IconData _activityIcon(String? type, String? category) {
    switch (type) {
      case 'expense':
        return Icons.receipt_long_rounded;
      case 'task':
        return dashboardCategoryIcon(category);
      default:
        return Icons.star_rounded;
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
        .replaceAll('Completó la tarea:', '')
        .replaceAll('Agregó un gasto:', '')
        .replaceAll('Canjeó un premio:', '')
        .replaceAll('  ', ' ')
        .trim();
  }

  String _firstName(String? name) {
    final value = name?.trim();
    if (value == null || value.isEmpty) return 'Alguien';
    return value.split(' ').first;
  }

  String _formatCurrency(double amount) {
    return '\$ ${NumberFormat.decimalPattern('es_AR').format(amount.round())}';
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return DateFormat('d MMM', 'es_AR').format(time);
  }
}
