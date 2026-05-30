import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/utils/amount_input.dart';

TextEditingValue _v(String text) => TextEditingValue(text: text);

void main() {
  group('ThousandsInputFormatter', () {
    final formatter = ThousandsInputFormatter();

    String format(String input) =>
        formatter.formatEditUpdate(const TextEditingValue(), _v(input)).text;

    test('groups thousands with dots', () {
      expect(format('1000'), '1.000');
      expect(format('10000'), '10.000');
      expect(format('100000'), '100.000');
      expect(format('1250000'), '1.250.000');
    });

    test('leaves small numbers untouched', () {
      expect(format('1'), '1');
      expect(format('999'), '999');
    });

    test('strips existing separators and reformats', () {
      expect(format('10.000'), '10.000');
      expect(format('1.0.0.0.0'), '10.000');
    });

    test('drops leading zeros but keeps a single zero', () {
      expect(format('007'), '7');
      expect(format('0'), '0');
    });

    test('empty input stays empty', () {
      expect(format(''), '');
      expect(format('abc'), '');
    });
  });

  group('parseAmountInput', () {
    test('parses dot-grouped thousands', () {
      expect(parseAmountInput('100.000'), 100000.0);
      expect(parseAmountInput('1.250.000'), 1250000.0);
    });

    test('parses decimal comma', () {
      expect(parseAmountInput('10,50'), 10.5);
    });

    test('plain and empty', () {
      expect(parseAmountInput('500'), 500.0);
      expect(parseAmountInput(''), 0.0);
    });
  });
}
