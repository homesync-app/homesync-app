import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/expenses/domain/models/receipt_scan_result.dart';

void main() {
  group('ReceiptScanResult.fromJson', () {
    test('lee los campos nuevos del servidor', () {
      final result = ReceiptScanResult.fromJson(
        {
          'merchant': 'Verdulería Juan',
          'amount': 12500,
          'date': '2026-10-01',
          'category': 'supermarket',
          'items': ['Papa', 'Cebolla'],
          'confidence': 0.95,
          'amountCheck': 'ok',
          'merchantTaxId': '30500010912',
          'merchantFromHistory': true,
        },
        '/tmp/ticket.webp',
        logId: 'log-1',
      );

      expect(result.itemNames, ['Papa', 'Cebolla']);
      expect(result.amountCheck, 'ok');
      expect(result.merchantTaxId, '30500010912');
      expect(result.merchantFromHistory, isTrue);
      expect(result.amountUncertain, isFalse);
    });

    test('monto que no cierra con las líneas es dudoso aunque la IA diga 0.95',
        () {
      final result = ReceiptScanResult.fromJson(
        {'amount': 12.5, 'confidence': 0.95, 'amountCheck': 'mismatch'},
        '/tmp/ticket.webp',
      );
      expect(result.amountUncertain, isTrue);
    });

    test('respuesta de un servidor viejo (sin campos nuevos) sigue andando', () {
      final result = ReceiptScanResult.fromJson(
        {'amount': 3000, 'confidence': 0.4, 'items': ['Leche']},
        '/tmp/ticket.webp',
      );
      expect(result.amountCheck, isNull);
      expect(result.merchantTaxId, isNull);
      expect(result.merchantFromHistory, isFalse);
      expect(result.amountUncertain, isTrue); // por confianza baja
    });

    test('sin monto nunca es "monto dudoso"', () {
      final result = ReceiptScanResult.fromJson(
        {'confidence': 0.2, 'amountCheck': 'mismatch'},
        '/tmp/ticket.webp',
      );
      expect(result.amountUncertain, isFalse);
    });
  });

  test('PossibleDuplicateExpense.fromJson tolera fecha inválida', () {
    final dup = PossibleDuplicateExpense.fromJson({
      'title': 'Super',
      'paidAt': 'no-es-fecha',
    });
    expect(dup.title, 'Super');
    expect(dup.paidAt, isNull);

    final ok = PossibleDuplicateExpense.fromJson({
      'title': 'Super',
      'paidAt': '2026-10-01T15:00:00+00:00',
    });
    expect(ok.paidAt, isNotNull);
  });
}
