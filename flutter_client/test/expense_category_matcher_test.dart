import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_category_matcher.dart';

void main() {
  group('resolveExpenseCategoryMatch', () {
    final List<Map<String, dynamic>> expenseCategories = [
      {'id': 'supermarket', 'name': 'Supermercado'},
      {'id': 'restaurants', 'name': 'Restaurantes'},
      {'id': 'settlement', 'name': 'Liquidacion'},
      {'id': 'other', 'name': 'Otros Gastos'},
    ];

    final List<Map<String, dynamic>> incomeCategories = [
      {'id': 'salary', 'name': 'Sueldo'},
      {'id': 'freelance', 'name': 'Freelance'},
      {'id': 'gift', 'name': 'Regalo'},
      {'id': 'other', 'name': 'Otros Ingresos'},
    ];

    test('keeps current state when title does not match any keyword', () {
      final result = resolveExpenseCategoryMatch(
        title: 'Compra indefinida',
        isIncome: false,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        selectedCategory: expenseCategories.last,
      );

      expect(result.isIncome, isFalse);
      expect(result.selectedCategory?['id'], 'other');
    });

    test('switches from expense mode to income mode for salary keywords', () {
      final result = resolveExpenseCategoryMatch(
        title: 'Cobro de sueldo abril',
        isIncome: false,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        selectedCategory: expenseCategories.first,
      );

      expect(result.isIncome, isTrue);
      expect(result.selectedCategory?['id'], 'salary');
    });

    test('switches from income mode to expense mode for supermarket keywords', () {
      final result = resolveExpenseCategoryMatch(
        title: 'Compra en supermercado',
        isIncome: true,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        selectedCategory: incomeCategories.first,
      );

      expect(result.isIncome, isFalse);
      expect(result.selectedCategory?['id'], 'supermarket');
    });

    test('updates category within the same mode when keyword matches', () {
      final result = resolveExpenseCategoryMatch(
        title: 'Cena y pizza',
        isIncome: false,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        selectedCategory: expenseCategories.first,
      );

      expect(result.isIncome, isFalse);
      expect(result.selectedCategory?['id'], 'restaurants');
    });

    test('matches settlement with accented keyword', () {
      final result = resolveExpenseCategoryMatch(
        title: 'Liquidación de deuda hogar',
        isIncome: false,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        selectedCategory: expenseCategories.first,
      );

      expect(result.isIncome, isFalse);
      expect(result.selectedCategory?['id'], 'settlement');
    });

    test('matches settlement with non-accented keyword', () {
      final result = resolveExpenseCategoryMatch(
        title: 'Liquidacion de deuda hogar',
        isIncome: false,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
        selectedCategory: expenseCategories.first,
      );

      expect(result.isIncome, isFalse);
      expect(result.selectedCategory?['id'], 'settlement');
    });
  });
}
