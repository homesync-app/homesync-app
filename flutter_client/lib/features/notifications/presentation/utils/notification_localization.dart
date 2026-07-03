import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/app_notification.dart';

/// Título y cuerpo localizados de una notificación.
///
/// Los RPCs/triggers escriben `type` + `params` estructurados (desde
/// 20260703110000); acá se mapean a claves ARB. Filas legadas (sin params) o
/// tipos desconocidos caen al `title`/`body` crudos del server (español) —
/// nunca devolvemos string vacío.
({String title, String body}) localizedNotificationContent(
  AppLocalizations t,
  AppNotification n, {
  String? localeName,
}) {
  final params = n.params;
  final fallback = (title: n.title, body: n.body);
  if (params == null) return fallback;

  String str(String key) => (params[key] as String?)?.trim() ?? '';

  String amount(String key) {
    final raw = params[key];
    final value = raw is num ? raw : num.tryParse('$raw');
    if (value == null) return '';
    final formatted =
        NumberFormat.decimalPattern(localeName ?? t.localeName).format(value);
    return '\$$formatted';
  }

  String date(String key) {
    final raw = params[key];
    final parsed = raw is String ? DateTime.tryParse(raw) : null;
    if (parsed == null) return '';
    try {
      return DateFormat('d MMM', localeName ?? t.localeName).format(parsed);
    } on Exception {
      // Sin date symbols para el locale (p. ej. tests sin
      // initializeDateFormatting): formato numérico neutro.
      return '${parsed.day}/${parsed.month}';
    }
  }

  switch (n.type) {
    case 'task_assigned':
      final actor = str('actor_name');
      final task = str('task_title');
      if (actor.isEmpty || task.isEmpty) return fallback;
      return (
        title: t.notifTaskAssignedTitle,
        body: t.notifTaskAssignedBody(actor, task),
      );
    case 'task_completed':
      final actor = str('actor_name');
      final task = str('task_title');
      if (actor.isEmpty || task.isEmpty) return fallback;
      return (
        title: t.notifTaskCompletedTitle,
        body: t.notifTaskCompletedBody(actor, task),
      );
    case 'task_pending_approval':
      final actor = str('actor_name');
      final task = str('task_title');
      if (actor.isEmpty || task.isEmpty) return fallback;
      return (
        title: t.notifTaskPendingApprovalTitle,
        body: t.notifTaskPendingApprovalBody(actor, task),
      );
    case 'task_approved':
      final task = str('task_title');
      final coins = params['coin_reward'];
      if (task.isEmpty || coins is! num) return fallback;
      return (
        title: t.notifTaskApprovedTitle,
        body: t.notifTaskApprovedBody(task, coins.toInt()),
      );
    case 'task_rejected':
      final task = str('task_title');
      if (task.isEmpty) return fallback;
      // El motivo del adulto viaja tal cual lo escribió (no se localiza).
      final reason = str('reason');
      return (
        title: t.notifTaskRejectedTitle,
        body: reason.isNotEmpty ? reason : t.notifTaskRejectedBody(task),
      );
    case 'expense_added':
      final actor = str('actor_name');
      final formattedAmount = amount('amount');
      if (actor.isEmpty || formattedAmount.isEmpty) return fallback;
      if (str('kind') == 'settlement') {
        return (
          title: t.notifSettlementTitle,
          body: t.notifSettlementBody(actor, formattedAmount),
        );
      }
      final title = str('expense_title');
      if (title.isEmpty) return fallback;
      return (
        title: t.notifExpenseAddedTitle,
        body: t.notifExpenseAddedBody(
          actor,
          str('kind'),
          title,
          formattedAmount,
        ),
      );
    case 'weekly_summary_ready':
      return (
        title: t.notifWeeklySummaryTitle,
        body: t.notifWeeklySummaryBody,
      );
    case 'planned_payment_upcoming':
      final title = str('expense_title');
      final formattedAmount = amount('amount');
      final dueDate = date('due_date');
      if (title.isEmpty || formattedAmount.isEmpty || dueDate.isEmpty) {
        return fallback;
      }
      return (
        title: t.notifPlannedUpcomingTitle(title),
        body: t.notifPlannedUpcomingBody(dueDate, formattedAmount),
      );
    case 'planned_payment_due':
      final title = str('expense_title');
      final formattedAmount = amount('amount');
      if (title.isEmpty || formattedAmount.isEmpty) return fallback;
      return (
        title: t.notifPlannedDueTitle(title),
        body: t.notifPlannedDueBody(formattedAmount),
      );
    default:
      return fallback;
  }
}
