import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/utils/amount_input.dart';

final _pesos = currencyByCode('ARS').inputFormat;
final _dollars = currencyByCode('USD').inputFormat;
final _euros = currencyByCode('EUR').inputFormat;

/// Types [keys] one by one at the caret, like a keyboard would.
TextEditingValue _type(
  AmountInputFormat format,
  String keys, {
  TextEditingValue start = TextEditingValue.empty,
}) {
  final formatter = AmountInputFormatter(format);
  var value = start;
  for (final key in keys.split('')) {
    final caret = value.selection.isValid
        ? value.selection.baseOffset
        : value.text.length;
    final text = value.text.replaceRange(caret, caret, key);
    value = formatter.formatEditUpdate(
      value,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: caret + 1),
      ),
    );
  }
  return value;
}

TextEditingValue _backspace(AmountInputFormat format, TextEditingValue value) {
  final caret = value.selection.baseOffset;
  return AmountInputFormatter(format).formatEditUpdate(
    value,
    TextEditingValue(
      text: value.text.replaceRange(caret - 1, caret, ''),
      selection: TextSelection.collapsed(offset: caret - 1),
    ),
  );
}

TextEditingValue _at(String text, int offset) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );

void main() {
  group('AppCurrency.inputFormat', () {
    test('pesos are whole units grouped with dots', () {
      expect(_pesos.decimals, 0);
      expect(_pesos.groupSeparator, '.');
    });

    test('dollars take cents with US separators', () {
      expect(_dollars.decimals, 2);
      expect(_dollars.groupSeparator, ',');
      expect(_dollars.decimalSeparator, '.');
    });

    test('euros take cents with Spanish separators', () {
      expect(_euros.decimals, 2);
      expect(_euros.groupSeparator, '.');
      expect(_euros.decimalSeparator, ',');
    });
  });

  group('AmountInputFormat.format', () {
    test('groups and rounds whole units', () {
      expect(_pesos.format(1250000), '1.250.000');
      expect(_pesos.format(12.6), '13');
    });

    test('is empty for zero so the hint shows', () {
      expect(_pesos.format(0), '');
      expect(_dollars.format(0), '');
    });

    test('shows cents only when there are some', () {
      expect(_dollars.format(1250.5), '1,250.50');
      expect(_dollars.format(12), '12');
      expect(_dollars.format(0.05), '0.05');
      expect(_euros.format(1250.5), '1.250,50');
    });
  });

  group('AmountInputFormat.parse', () {
    test('reads its own text back', () {
      expect(_pesos.parse('1.250.000'), 1250000);
      expect(_dollars.parse('1,250.50'), 1250.5);
      expect(_euros.parse('1.250,50'), 1250.5);
    });

    test('reads toString values without multiplying them', () {
      // Editing an expense prefilled `1500.0`, which saved as 15000.
      expect(_pesos.parse('1500.0'), 1500);
      expect(_dollars.parse('12.5'), 12.5);
      expect(_euros.parse('12.5'), 12.5);
    });

    test('a lone group separator with three digits is grouping', () {
      expect(_pesos.parse('12.500'), 12500);
      expect(_dollars.parse('12,500'), 12500);
    });

    test('with both separators the last one is the decimal point', () {
      expect(_dollars.parse('1.250,50'), 1250.5);
      expect(_euros.parse('1,250.50'), 1250.5);
    });

    test('rounds whole units and caps decimals', () {
      expect(_pesos.parse('12,5'), 13);
      expect(_dollars.parse('1.2345'), 1.23);
    });

    test('empty or unreadable text is zero', () {
      expect(_pesos.parse(''), 0);
      expect(_dollars.parse('abc'), 0);
      expect(_euros.parse(','), 0);
    });
  });

  group('AmountInputFormatter', () {
    test('groups thousands while typing', () {
      expect(_type(_pesos, '1250000').text, '1.250.000');
      expect(_type(_dollars, '1250000').text, '1,250,000');
    });

    test('drops leading zeros', () {
      expect(_type(_pesos, '007').text, '7');
      expect(_type(_pesos, '0').text, '0');
    });

    test('ignores separators in whole units', () {
      expect(_type(_pesos, '12,50').text, '1.250');
      expect(_type(_pesos, '12.50').text, '1.250');
    });

    test('either separator key starts the cents', () {
      // A `.` typed for cents became a thousands dot: 12.50 read as 1250.
      expect(_type(_dollars, '12.50').text, '12.50');
      expect(_type(_dollars, '12,50').text, '12.50');
      expect(_type(_euros, '12.50').text, '12,50');
      expect(_type(_euros, '1250,5').text, '1.250,5');
    });

    test('caps decimals and keeps a single decimal separator', () {
      expect(_type(_dollars, '12.345').text, '12.34');
      expect(_type(_dollars, '1..5').text, '1.5');
    });

    test('a separator typed first becomes 0 and the separator', () {
      expect(_type(_dollars, '.5').text, '0.5');
    });

    test('typed text parses to the amount the user meant', () {
      expect(_dollars.parse(_type(_dollars, '1250.75').text), 1250.75);
      expect(_euros.parse(_type(_euros, '99,9').text), 99.9);
      expect(_pesos.parse(_type(_pesos, '150000').text), 150000);
    });

    test('backspace at the end deletes the last digit', () {
      final value = _backspace(_pesos, _at('1.250', 5));
      expect(value.text, '125');
      expect(value.selection.baseOffset, 3);
    });

    test('backspace on a thousands separator deletes the digit before it', () {
      final value = _backspace(_pesos, _at('1.250', 2));
      expect(value.text, '250');
      expect(value.selection.baseOffset, 0);
    });

    test('typing in the middle keeps the digit order', () {
      final value = _type(_pesos, '98', start: _at('1.250', 1));
      expect(value.text, '198.250');
    });

    test('a paste is read and rewritten in the format', () {
      final formatter = AmountInputFormatter(_euros);
      final pasted = formatter.formatEditUpdate(
        TextEditingValue.empty,
        _at('1250.50', 7),
      );
      expect(pasted.text, '1.250,50');
      expect(pasted.selection.baseOffset, pasted.text.length);
    });
  });

  group('AppCurrency.format', () {
    test('pesos stay whole', () {
      expect(currencyByCode('ARS').format(1250.4), '\$\u00A01.250');
    });

    test('cents show only when there are some', () {
      final usd = currencyByCode('USD');
      expect(usd.format(12.5), '\$12.50');
      expect(usd.format(12), '\$12');
      expect(usd.format(12.6, decimalDigits: 0), '\$13');
    });
  });
}
