import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/utils/display_text.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';

void main() {
  group('DisplayTextX', () {
    test('filters null-like values', () {
      expect(null.toDisplayTextOrNull(), isNull);
      expect(''.toDisplayTextOrNull(), isNull);
      expect('   '.toDisplayTextOrNull(), isNull);
      expect('null'.toDisplayTextOrNull(), isNull);
      expect(' NULL '.toDisplayTextOrNull(), isNull);
    });

    test('trims usable values and applies placeholders', () {
      expect('  Mercado  '.toDisplayTextOrNull(), 'Mercado');
      expect('Mercado'.displayTextOr(), 'Mercado');
      expect('null'.displayTextOr('Sin dato'), 'Sin dato');
      expect(''.hasDisplayText, isFalse);
      expect('Casa'.hasDisplayText, isTrue);
    });
  });

  group('ShoppingItemModel display text', () {
    test('does not compose null-like quantity values', () {
      ShoppingItemModel item({
        String? quantity,
        String? unit,
        String? addedByName,
      }) {
        return ShoppingItemModel(
          id: 'item-1',
          householdId: 'household-1',
          name: 'Leche',
          quantity: quantity,
          unit: unit,
          addedByName: addedByName,
          createdAt: DateTime(2026),
        );
      }

      expect(item(quantity: '2', unit: 'null').displayQuantity, '2');
      expect(item(quantity: null, unit: 'kg').displayQuantity, 'kg');
      expect(item(quantity: ' null ', unit: '   ').displayQuantity, '');
      expect(item(addedByName: ' null ').addedByDisplay, '');
      expect(item(addedByName: '  Blas Casa ').addedByDisplay, 'Blas');
    });
  });
}
