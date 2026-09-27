import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';

/// El icono de un gasto se deduce del titulo. Panaderia, cafe y postres
/// estaban agrupados, y una compra en la panaderia mostraba un helado.
void main() {
  IconData iconFor(String title, {String category = 'supermarket'}) =>
      CategoryMapping.getSmartExpenseDisplayIcon(category, title: title);

  group('getSmartExpenseDisplayIcon', () {
    test('panaderia y facturas muestran pan, no helado', () {
      for (final title in [
        'Panadería',
        'Panaderia del barrio',
        'Medialunas',
        'Pastelería',
        'Bakery',
      ]) {
        expect(iconFor(title), Icons.bakery_dining_rounded, reason: title);
      }
    });

    test('cafe muestra una taza', () {
      for (final title in ['Café', 'Cafe con Sofi', 'Cafetería', 'Coffee']) {
        expect(iconFor(title), Icons.local_cafe_rounded, reason: title);
      }
    });

    test('helado y postres siguen con el helado', () {
      for (final title in ['Helado', 'Heladería', 'Postre', 'Ice cream']) {
        expect(iconFor(title), Icons.icecream_rounded, reason: title);
      }
    });

    test('las palabras se matchean enteras', () {
      // "cafetera" no es un cafe: no debe tomar el icono de taza.
      expect(iconFor('Cafetera nueva'), isNot(Icons.local_cafe_rounded));
    });

    test('cada grupo tiene su propio color', () {
      Color colorFor(String title) =>
          CategoryMapping.getSmartExpenseDisplayColor(
            'supermarket',
            title: title,
          );
      final bakery = colorFor('Panadería');
      final cafe = colorFor('Café');
      final dessert = colorFor('Helado');
      expect({bakery, cafe, dessert}.length, 3);
    });
  });
}
