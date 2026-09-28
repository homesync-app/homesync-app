import 'dart:math' as math;

import 'package:flutter/services.dart';

/// How a money field writes numbers: separators and decimal places.
///
/// Built from the user's currency (`AppCurrency.inputFormat`) so the field
/// reads like the amounts on screen: `12.500` for pesos, `1,250.50` for
/// dollars. Grouping is done by hand so it never depends on `intl` locale data
/// being initialized (which can silently fail and leave the field unformatted).
class AmountInputFormat {
  const AmountInputFormat({
    this.groupSeparator = '.',
    this.decimalSeparator = ',',
    this.decimals = 0,
  });

  /// Whole units grouped with dots, the peso convention: `12.500`.
  static const wholeUnits = AmountInputFormat();

  final String groupSeparator;
  final String decimalSeparator;

  /// Decimal places the field takes; 0 means whole units only.
  final int decimals;

  bool get allowsDecimals => decimals > 0;

  /// Numeric keyboard, with a decimal key only when the field takes one.
  TextInputType get keyboardType =>
      TextInputType.numberWithOptions(decimal: allowsDecimals);

  /// Text that prefills a field with [value]. Empty for zero or less, so the
  /// hint shows instead of a `0` the user has to delete.
  String format(num value) {
    if (value <= 0) return '';
    if (!allowsDecimals) return _group(value.round().toString());
    final scale = math.pow(10, decimals).toInt();
    final scaled = (value * scale).round();
    final whole = _group((scaled ~/ scale).toString());
    final fraction = scaled % scale;
    if (fraction == 0) return whole;
    return '$whole$decimalSeparator'
        '${fraction.toString().padLeft(decimals, '0')}';
  }

  /// Reads a field back into a number; 0 when there is nothing to read.
  ///
  /// Takes this format's own text and also plain values such as
  /// `toString()` output: with both separators present the last one is the
  /// decimal point, and a lone group separator followed by one or two digits
  /// is read as decimals, so `1500.0` stays 1500 instead of becoming 15000.
  /// Whole-unit formats round the result.
  double parse(String text) {
    final cleaned = text.replaceAll(RegExp('[^0-9.,]'), '');
    if (!cleaned.contains(RegExp('[0-9]'))) return 0;
    final decimalAt = _decimalIndex(cleaned);
    final wholeDigits = _digits(
      decimalAt < 0 ? cleaned : cleaned.substring(0, decimalAt),
    );
    final fractionDigits =
        decimalAt < 0 ? '' : _digits(cleaned.substring(decimalAt + 1));
    final value = double.parse(
      '${wholeDigits.isEmpty ? '0' : wholeDigits}.'
      '${fractionDigits.isEmpty ? '0' : fractionDigits}',
    );
    if (!allowsDecimals) return value.roundToDouble();
    final scale = math.pow(10, decimals);
    return (value * scale).round() / scale;
  }

  int _decimalIndex(String text) {
    final lastDot = text.lastIndexOf('.');
    final lastComma = text.lastIndexOf(',');
    if (lastDot >= 0 && lastComma >= 0) return math.max(lastDot, lastComma);
    final index = math.max(lastDot, lastComma);
    if (index < 0) return -1;
    final separator = text[index];
    // Repeated, it can only be grouping: 1.250.000.
    if (separator.allMatches(text).length > 1) return -1;
    if (separator == decimalSeparator) return index;
    final trailing = text.length - index - 1;
    return trailing >= 1 && trailing <= 2 ? index : -1;
  }

  String _group(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(groupSeparator);
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String _digits(String text) => text.replaceAll(RegExp('[^0-9]'), '');
}

/// Live formatter for money fields.
///
/// Groups thousands as the user types and, when [format] takes decimals,
/// turns a typed `.` or `,` into its decimal separator: phone keyboards show
/// only one of the two, and a `.` typed for cents must not become a thousands
/// dot (that turned `12.50` into 1250). Extra decimals and a second decimal
/// separator are ignored, the caret stays next to the digit it was on, and a
/// backspace on a thousands separator deletes the digit before it.
class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter(this.format);

  final AmountInputFormat format;

  static final _digit = RegExp('[0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final previous = oldValue.text;
    var text = newValue.text;
    final selection = newValue.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      return _rewrite(text);
    }
    var caret = selection.baseOffset;
    // Positions of the decimal separator in `text`, when there is one.
    var decimalAt = -1;

    final inserted = text.length == previous.length + 1 &&
        caret > 0 &&
        text.substring(0, caret - 1) == previous.substring(0, caret - 1) &&
        text.substring(caret) == previous.substring(caret - 1);
    final deleted = text.length == previous.length - 1 &&
        text.substring(0, caret) == previous.substring(0, caret) &&
        text.substring(caret) == previous.substring(caret + 1);

    if (inserted) {
      final char = text[caret - 1];
      if (!_digit.hasMatch(char)) {
        final isDecimalKey = char == '.' || char == ',';
        final hasDecimal = _decimalIndexIn(previous) >= 0;
        if (!isDecimalKey || !format.allowsDecimals || hasDecimal) {
          return oldValue;
        }
        decimalAt = caret - 1;
      }
    } else if (deleted) {
      final removed = previous[caret];
      final previousDecimal = _decimalIndexIn(previous);
      final inWholePart = previousDecimal < 0 || caret < previousDecimal;
      if (removed == format.groupSeparator &&
          inWholePart &&
          caret > 0 &&
          _digit.hasMatch(text[caret - 1])) {
        text = text.substring(0, caret - 1) + text.substring(caret);
        caret -= 1;
      }
    } else {
      // Paste, autofill or a replaced selection: read the value and write it
      // back in this format.
      return _rewrite(text);
    }

    if (decimalAt < 0) decimalAt = _decimalIndexIn(text);

    final wholeRaw = decimalAt < 0 ? text : text.substring(0, decimalAt);
    final fractionRaw = decimalAt < 0 ? '' : text.substring(decimalAt + 1);
    var whole = AmountInputFormat._digits(wholeRaw);
    final fraction = AmountInputFormat._digits(fractionRaw);
    if (fraction.length > format.decimals) return oldValue;

    // Digits (plus the decimal separator) right of the caret: the anchor that
    // survives regrouping and dropped zeros on the left.
    var anchor = 0;
    for (var i = caret; i < text.length; i++) {
      if (_digit.hasMatch(text[i]) || i == decimalAt) anchor++;
    }

    whole = whole.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final hasDecimal = decimalAt >= 0;
    if (whole.isEmpty && !hasDecimal) {
      return const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    if (whole.isEmpty) whole = '0';

    final result = hasDecimal
        ? '${format._group(whole)}${format.decimalSeparator}$fraction'
        : format._group(whole);
    final resultDecimal =
        hasDecimal ? result.lastIndexOf(format.decimalSeparator) : -1;

    var offset = result.length;
    var seen = 0;
    while (offset > 0 && seen < anchor) {
      offset--;
      if (_digit.hasMatch(result[offset]) || offset == resultDecimal) seen++;
    }
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  /// Index of the decimal separator in text this formatter wrote, or -1.
  int _decimalIndexIn(String text) {
    if (!format.allowsDecimals) return -1;
    return text.indexOf(format.decimalSeparator);
  }

  TextEditingValue _rewrite(String text) {
    final formatted = format.format(format.parse(text));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
