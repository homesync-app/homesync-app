import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';

// intl separa símbolo y número con un espacio que no corta línea.
const _nbsp = '\u00A0';

void main() {
  group('AppCurrency.format', () {
    test('ARS lleva el símbolo adelante con separadores de es', () {
      final ars = currencyByCode('ARS');
      expect(ars.format(12500), '\$${_nbsp}12.500');
      expect(ars.format(12500.5, decimalDigits: 2), '\$${_nbsp}12.500,50');
    });

    test('el signo va antes del símbolo', () {
      final ars = currencyByCode('ARS');
      expect(ars.format(-12500), '-\$${_nbsp}12.500');
      expect(ars.format(12500, signed: true), '+\$${_nbsp}12.500');
      expect(ars.format(0, signed: true), '\$${_nbsp}0');
    });

    test('CLP y UYU siguen la misma convención local', () {
      expect(currencyByCode('CLP').format(12500), '\$${_nbsp}12.500');
      expect(currencyByCode('UYU').format(12500), '\$U${_nbsp}12.500');
    });

    test('los locales con datos propios conservan su formato', () {
      expect(currencyByCode('USD').format(12500), '\$12,500');
      expect(currencyByCode('BRL').format(12500), 'R\$${_nbsp}12.500');
      expect(currencyByCode('EUR').format(12500), '12.500$_nbsp€');
    });

    test('un código desconocido cae en ARS', () {
      expect(currencyByCode('XYZ').code, 'ARS');
      expect(currencyByCode(null).code, 'ARS');
    });
  });

  group('AppCurrency.formatCompact', () {
    test('ARS compacto mantiene el símbolo adelante', () {
      final ars = currencyByCode('ARS');
      expect(ars.formatCompact(12500), '\$${_nbsp}12,5${_nbsp}mil');
      expect(ars.formatCompact(1250000), '\$${_nbsp}1,25${_nbsp}M');
      expect(ars.formatCompact(-950), '-\$${_nbsp}950');
    });

    test('USD compacto usa la forma corta de en_US', () {
      expect(currencyByCode('USD').formatCompact(12500), '\$12.5K');
    });
  });
}
