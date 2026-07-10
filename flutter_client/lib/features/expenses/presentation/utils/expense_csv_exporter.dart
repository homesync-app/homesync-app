import 'dart:io';

import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/presentation/utils/finance_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Exporta los movimientos reales del mes en curso a CSV y abre el share
/// sheet del sistema. Separador ';' y decimales con coma (convención del
/// Excel es-AR) + BOM UTF-8 para que Excel no rompa las tildes.
class ExpenseCsvExporter {
  /// Devuelve la cantidad de filas exportadas; con 0 no genera ni comparte.
  static Future<int> exportCurrentMonth({
    required List<FeedItemModel> feed,
    required AppLocalizations t,
    required String localeTag,
  }) async {
    final now = DateTime.now();
    final items = feed
        .where(
          (item) =>
              item.isRealExpense &&
              item.date.month == now.month &&
              item.date.year == now.year,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (items.isEmpty) return 0;

    final amountFormat = NumberFormat('0.##', localeTag);
    final buffer = StringBuffer()
      ..writeln(
        [
          t.csvHeaderDate,
          t.csvHeaderType,
          t.csvHeaderTitle,
          t.csvHeaderCategory,
          t.csvHeaderAmount,
          t.csvHeaderPayer,
          t.csvHeaderSplit,
        ].map(_escape).join(';'),
      );

    for (final item in items) {
      buffer.writeln(
        [
          DateFormat('yyyy-MM-dd').format(item.date),
          _typeLabel(t, item.transactionType),
          localizedFinanceTitle(
            t,
            title: item.title,
            titleKey: item.titleKey,
            category: item.category,
            transactionType: item.transactionType,
          ),
          localizedFinanceCategoryName(
            t,
            item.category,
            isIncome: item.transactionType == 'income',
          ),
          amountFormat.format(item.amount),
          item.payerDisplayName,
          _splitLabel(t, item.splitType),
        ].map(_escape).join(';'),
      );
    }

    final monthTag = DateFormat('yyyy-MM').format(now);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/homesync_finanzas_$monthTag.csv');
    // BOM UTF-8: sin esto Excel (Windows) muestra las tildes rotas.
    await file.writeAsString('\uFEFF$buffer');

    final rawMonth = DateFormat.yMMMM(localeTag).format(now);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: t.exportCsvShareSubject(rawMonth),
      ),
    );

    return items.length;
  }

  static String _typeLabel(AppLocalizations t, String transactionType) {
    switch (transactionType) {
      case 'income':
        return t.csvTypeIncome;
      case 'settlement':
        return t.csvTypeSettlement;
      default:
        return t.csvTypeExpense;
    }
  }

  static String _splitLabel(AppLocalizations t, String? splitType) {
    switch ((splitType ?? '').toLowerCase()) {
      case 'equal':
        return t.expensesFormSplitShared;
      case 'fixed':
        return t.expensesFormSplitFixed;
      case 'gift':
        return t.expensesFormSplitGift;
      case 'personal':
        return t.expensesFormSplitPersonal;
      default:
        return '';
    }
  }

  static String _escape(String value) {
    if (value.contains(';') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
