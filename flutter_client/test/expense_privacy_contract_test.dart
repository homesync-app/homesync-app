import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';

void main() {
  group('Expense privacy contract', () {
    test('infers private when split_type is personal and is_shared omitted',
        () {
      final model = ExpenseModel.fromJson({
        'id': 'exp-1',
        'title': 'Gasto personal',
        'amount': 100,
        'household_id': 'h-1',
        'paid_by': 'u-1',
        'split_type': 'personal',
        'created_at': '2026-03-21T10:00:00Z',
        'paid_at': '2026-03-21T10:00:00Z',
      });

      expect(model.isShared, isFalse);
    });

    test('infers private when split_type is gift and is_shared omitted', () {
      final model = ExpenseModel.fromJson({
        'id': 'exp-2',
        'title': 'Regalo',
        'amount': 50,
        'household_id': 'h-1',
        'paid_by': 'u-1',
        'split_type': 'gift',
        'created_at': '2026-03-21T10:00:00Z',
        'paid_at': '2026-03-21T10:00:00Z',
      });

      expect(model.isShared, isFalse);
    });

    test('keeps explicit is_shared from backend when present', () {
      final model = ExpenseModel.fromJson({
        'id': 'exp-3',
        'title': 'Compra compartida',
        'amount': 75,
        'household_id': 'h-1',
        'paid_by': 'u-1',
        'split_type': 'equal',
        'is_shared': true,
        'created_at': '2026-03-21T10:00:00Z',
        'paid_at': '2026-03-21T10:00:00Z',
      });

      expect(model.isShared, isTrue);
    });
  });
}
