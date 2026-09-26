import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/premium/domain/premium_pricing.dart';

void main() {
  group('annualSavingsPercent', () {
    test('calcula el ahorro real contra 12 meses y redondea para abajo', () {
      // 12 × 2.99 = 35.88; 23.99 / 35.88 = 0.6686 → 33.1% → 33.
      expect(
        annualSavingsPercent(annualPrice: 23.99, monthlyPrice: 2.99),
        33,
      );
      // Justo 20%: no se infla a 21 ni se redondea a 19 por flotantes.
      expect(
        annualSavingsPercent(annualPrice: 96, monthlyPrice: 10),
        20,
      );
    });

    test('oculta el badge si el ahorro es chico o no hay ahorro', () {
      expect(annualSavingsPercent(annualPrice: 115, monthlyPrice: 10), isNull);
      expect(annualSavingsPercent(annualPrice: 130, monthlyPrice: 10), isNull);
    });

    test('precios inválidos no producen un porcentaje', () {
      expect(annualSavingsPercent(annualPrice: 0, monthlyPrice: 10), isNull);
      expect(annualSavingsPercent(annualPrice: 50, monthlyPrice: 0), isNull);
    });
  });
}
