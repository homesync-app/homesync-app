import 'package:flutter/services.dart';

/// Live thousands-separator formatter for money inputs, using the app's
/// convention (dot as thousands separator: 10.000, 1.250.000).
///
/// Integer-only (savings/expense amounts are whole units in this app). It keeps
/// the caret at the end after reformatting. Grouping is done manually so it does
/// NOT depend on `intl` locale data being initialized (which can silently fail
/// and leave the input unformatted).
class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip any non-digit (existing separators included) and reformat.
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Drop leading zeros but keep a single zero.
    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final formatted = _groupThousands(normalized);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _groupThousands(String digits) {
    final buffer = StringBuffer();
    final len = digits.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// Parses a money string formatted with dot-thousands / comma-decimals back
/// into a double. Handles plain numbers, thousands dots (10.000), and decimal
/// commas (10,50).
double parseAmountInput(String value) {
  final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
  if (normalized.isEmpty) return 0.0;
  return double.tryParse(normalized) ?? 0.0;
}
