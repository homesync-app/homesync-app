import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';

void main() {
  group('Finance feed contract parsing', () {
    test('parses real expense with transaction_type and payer fields', () {
      final item = FeedItemModel.fromJson({
        'record_type': 'expense',
        'transaction_type': 'income',
        'id': 'exp-1',
        'title': 'Sueldo',
        'amount': 2500.75,
        'category': 'salary',
        'split_type': 'personal',
        'payer_id': 'user-1',
        'payer_email': 'test@example.com',
        'payer_full_name': 'User Test',
        'payer_avatar_url': 'https://example.com/a.png',
        'date': '2026-03-19T10:00:00Z',
        'status': 'paid',
      });

      expect(item.isRealExpense, isTrue);
      expect(item.isPlanned, isFalse);
      expect(item.transactionType, equals('income'));
      expect(item.payerDisplayName, equals('User'));
      expect(item.formattedAmount, equals(r'$2500.75'));
    });

    test('defaults planned item transaction type to expense when omitted', () {
      final item = FeedItemModel.fromJson({
        'record_type': 'planned',
        'id': 'pln-1',
        'title': 'Netflix',
        'amount': 10,
        'payer_id': 'user-1',
        'date': '2026-03-19T00:00:00Z',
        'status': 'pending',
      });

      expect(item.isPlanned, isTrue);
      expect(item.transactionType, equals('expense'));
      expect(item.isPending, isTrue);
    });

    test('identifies settlement transaction type correctly', () {
      final item = FeedItemModel.fromJson({
        'record_type': 'expense',
        'transaction_type': 'settlement',
        'id': 'set-1',
        'title': 'Liquidación',
        'amount': 100,
        'payer_id': 'user-1',
        'date': '2026-03-19T00:00:00Z',
        'status': 'paid',
      });

      expect(item.isSettlement, isTrue);
      expect(item.isRealExpense, isTrue);
    });
  });
}
