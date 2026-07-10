import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/utils/finance_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dismissedPrefsKey = 'homesync_subscription_suggestion_dismissed';

/// Candidato a gasto recurrente detectado en el feed.
class SubscriptionSuggestion {
  final String normalizedKey;
  final String title;
  final String? category;
  final double avgAmount;
  final int distinctMonths;
  final int suggestedDayOfMonth;

  const SubscriptionSuggestion({
    required this.normalizedKey,
    required this.title,
    required this.category,
    required this.avgAmount,
    required this.distinctMonths,
    required this.suggestedDayOfMonth,
  });
}

/// Heurística client-side: un título normalizado que aparece en 2+ meses
/// distintos con montos parecidos (±30%) y todavía no tiene plantilla
/// recurrente es, casi seguro, una suscripción o gasto fijo. Devuelve el
/// mejor candidato (más meses, luego más reciente) o null.
///
/// Exclusiones deliberadas: liquidaciones y mesadas (no son consumo),
/// supermercado (se repite pero no es un fijo), y títulos ya descartados por
/// el usuario (persistido en SharedPreferences).
final subscriptionSuggestionProvider =
    FutureProvider.autoDispose<SubscriptionSuggestion?>((ref) async {
  final feed = await ref.watch(combinedFeedControllerProvider.future);
  final templates = await ref.watch(expenseTemplateControllerProvider.future);

  final prefs = await SharedPreferences.getInstance();
  final dismissed =
      (prefs.getStringList(_dismissedPrefsKey) ?? const <String>[]).toSet();

  final templateKeys = <String>{
    for (final template in templates)
      normalizeFinanceToken(template.title),
  }..removeWhere((key) => key.isEmpty);

  const excludedCategories = {
    'settlement',
    'allowance',
    'supermarket',
    'groceries',
  };

  final now = DateTime.now();
  final windowStart = DateTime(now.year, now.month - 3, now.day);

  final groups = <String, List<FeedItemModel>>{};
  for (final item in feed) {
    if (!item.isRealExpense || item.transactionType != 'expense') continue;
    if (item.date.isBefore(windowStart)) continue;
    if (excludedCategories.contains((item.category ?? '').toLowerCase())) {
      continue;
    }

    final key = normalizeFinanceToken(item.title);
    if (key.length < 3) continue;
    if (dismissed.contains(key)) continue;
    if (templateKeys.contains(key)) continue;

    groups.putIfAbsent(key, () => []).add(item);
  }

  SubscriptionSuggestion? best;
  DateTime? bestLatest;
  for (final entry in groups.entries) {
    final items = entry.value;
    final months = items.map((i) => '${i.date.year}-${i.date.month}').toSet();
    if (months.length < 2) continue;

    final amounts = items.map((i) => i.amount).toList();
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    final minAmount = amounts.reduce((a, b) => a < b ? a : b);
    if (maxAmount <= 0 || (maxAmount - minAmount) / maxAmount > 0.30) {
      continue;
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    final latest = items.first;
    final avg =
        amounts.fold<double>(0, (sum, a) => sum + a) / amounts.length;

    final candidate = SubscriptionSuggestion(
      normalizedKey: entry.key,
      title: latest.title,
      category: latest.category,
      avgAmount: avg,
      distinctMonths: months.length,
      suggestedDayOfMonth: latest.date.day,
    );

    final isBetter = best == null ||
        candidate.distinctMonths > best.distinctMonths ||
        (candidate.distinctMonths == best.distinctMonths &&
            latest.date.isAfter(bestLatest!));
    if (isBetter) {
      best = candidate;
      bestLatest = latest.date;
    }
  }

  return best;
});

/// Persiste el descarte de una sugerencia (para siempre). El caller debe
/// invalidar [subscriptionSuggestionProvider] después.
Future<void> persistSubscriptionSuggestionDismissal(
  String normalizedKey,
) async {
  final prefs = await SharedPreferences.getInstance();
  final dismissed =
      (prefs.getStringList(_dismissedPrefsKey) ?? const <String>[]).toSet()
        ..add(normalizedKey);
  await prefs.setStringList(_dismissedPrefsKey, dismissed.toList());
}
