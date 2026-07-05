import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart'
    show dashboardCategoryAccent, dashboardCategoryIcon;
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_detail_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/task_detail_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Shared presentation logic for activity-feed entries.
///
/// Both renderers of the home activity feed — [ActivityChatBubble] (couple,
/// family, friends: conversation metaphor) and [SoloActivityTile] (solo:
/// full-width timeline) — parse the same activity maps and open the same
/// detail sheets. This file is the single source of truth for that logic so
/// the two widgets can't drift apart.

int? activityReadInt(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw.toString());
}

double? activityParseAmount(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw.toString());
}

/// Un equilibrio de saldo (settle_debt_v1) llega como expense con
/// type='settlement' en metadata. Se presenta distinto en todas las
/// superficies del feed (titulo, icono, detalle) para que no aparezca como un
/// gasto "Otros".
bool activityIsSettlement(Map<String, dynamic> data) =>
    data['type'] == 'settlement';

/// Titulo unificado de un equilibrio de saldo. Single source of truth para
/// chat bubble, solo tile, family feed y la hoja de detalle.
const String activitySettlementTitle = 'Balance equilibrado';

String localizedActivityTitle(
  AppLocalizations t,
  Map<String, dynamic> data,
) {
  if (activityIsSettlement(data)) return activitySettlementTitle;
  final fallback =
      data['task_title'] ?? data['title'] ?? data['description'] ?? 'Actividad';
  return localizedTaskCatalogText(
    t,
    data['title_key'] as String?,
    fallback.toString(),
  );
}

String activityDisplayTitle(Object? rawTitle, String? category) {
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

String _normalizedText(String raw) {
  // Los patrones mojibake (UTF-8 leído como Latin-1 en datos viejos) escriben
  // su segundo caracter con escape \u para no disparar el guard de encoding
  // del repo (test/text_encoding_guard_test.dart, mismo truco que usa el
  // propio guard): son datos a reparar, no un error de encoding del archivo.
  return raw
      .replaceAll('CompletÃ\u00B3 la tarea:', '')
      .replaceAll('AgregÃ\u00B3 un gasto:', '')
      .replaceAll('CanjeÃ\u00B3 un premio:', '')
      .replaceAll('Ã\u00B3', 'ó')
      .replaceAll('Ã\u00A1', 'á')
      .replaceAll('Ã\u00A9', 'é')
      .replaceAll('Ã\u00AD', 'í')
      .replaceAll('Ã\u00BA', 'ú')
      .replaceAll('Ã\u00B1', 'ñ')
      .replaceAll('Â¿', '¿')
      .replaceAll('Â¡', '¡')
      .replaceAll('  ', ' ')
      .trim();
}

Color activityAccent(
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

IconData activityIcon(
  String? type,
  String? category, {
  bool isSettlement = false,
}) {
  if (isSettlement) return Icons.handshake_rounded;
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

String formatActivityTimeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
  if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
  return DateFormat('d MMM', 'es_AR').format(time);
}

String formatTaskActivityTimeLabel(Map<String, dynamic> activity) {
  final createdAt =
      DateTime.tryParse(activity['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now();
  final data = (activity['data'] as Map<String, dynamic>?) ?? {};
  final completedAtRaw = data['completed_at'];
  final completedAt = DateTime.tryParse(completedAtRaw?.toString() ?? '');

  if (activity['type'] == 'task' && completedAt != null) {
    final createdDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final completedDateOnly = data['completed_date_only'] == true ||
        data['completed_date_only']?.toString().toLowerCase() == 'true' ||
        _looksLikeDateOnlyTimestamp(completedAtRaw);
    final effectiveCompletedAt =
        completedDateOnly ? completedAt : completedAt.toLocal();
    final completedDay = DateTime(
      effectiveCompletedAt.year,
      effectiveCompletedAt.month,
      effectiveCompletedAt.day,
    );
    final dayDiff = createdDay.difference(completedDay).inDays;
    if (dayDiff > 0) {
      return dayDiff == 1 ? 'Hecha ayer' : 'Hecha hace $dayDiff días';
    }
  }

  return formatActivityTimeAgo(createdAt);
}

bool _looksLikeDateOnlyTimestamp(dynamic raw) {
  final normalized = raw?.toString().replaceFirst(' ', 'T');
  if (normalized == null) return false;
  return normalized.contains('T00:00:00') || normalized.contains('T12:00:00');
}

/// Opens the right detail sheet for a feed activity (task or expense).
/// Reward activities have no detail sheet and are a no-op.
Future<void> openActivityDetail(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> activity,
) async {
  final type = activity['type'] as String?;
  final data = (activity['data'] as Map<String, dynamic>?) ?? {};

  if (type == 'task') {
    final completedAt = data['completed_at'] ??
        data['last_completed_at'] ??
        activity['created_at'];
    final taskData = <String, dynamic>{
      ...data,
      'title': data['task_title'] ?? data['title'],
      'category': data['category'] ?? 'limpieza',
      'xp_reward': data['xp_reward'] ?? data['xp_per_user'] ?? data['xp'],
      'coin_reward':
          data['coins_reward'] ?? data['coins_per_user'] ?? data['coins'],
      'completed_at': completedAt,
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
        title: activityIsSettlement(data)
            ? activitySettlementTitle
            : data['title']?.toString() ?? '',
        titleKey: data['title_key']?.toString(),
        amount: activityParseAmount(data['amount']) ?? 0,
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
