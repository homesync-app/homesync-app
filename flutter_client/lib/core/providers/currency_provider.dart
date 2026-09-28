import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/theme_provider.dart'
    show sharedPreferencesProvider;
import 'package:homesync_client/core/utils/amount_input.dart';
import 'package:intl/intl.dart';

const _kCurrencyKey = 'app_currency_code';

/// Symbol first, separated by a non-breaking space: `$ 12.500`.
const _kSymbolFirstPattern = '\u00A4\u00A0#,##0.00';

/// A currency the user can pick in Settings. Display names live in the ARB
/// files (`currencyName*`), not here.
class AppCurrency {
  final String code;
  final String symbol;
  final String locale;

  /// Forces `$ 12.500` instead of the locale's own pattern.
  ///
  /// `intl` ships no number data for es_AR, es_CL or es_UY and falls back to
  /// generic `es`, which renders `12.500 $` (the Spain convention). These
  /// currencies keep the `es` separators but put the symbol first, as people
  /// write them locally.
  final bool symbolFirst;

  /// Decimal places amount fields take: none for pesos, where people type
  /// whole amounts, and cents for dollars, euros and reais.
  final int inputDecimals;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.locale,
    this.symbolFirst = false,
    this.inputDecimals = 0,
  });

  /// How amount fields read and write numbers in this currency.
  AmountInputFormat get inputFormat {
    final english = locale.startsWith('en');
    return AmountInputFormat(
      groupSeparator: english ? ',' : '.',
      decimalSeparator: english ? '.' : ',',
      decimals: inputDecimals,
    );
  }

  /// Formats [amount] for display. Without [decimalDigits], cents show only
  /// for currencies that take them and only when there are some: `$12.50`
  /// and `$12`, while pesos stay whole (`$ 12.500`).
  String format(
    num amount, {
    bool signed = false,
    int? decimalDigits,
  }) {
    final value = amount.toDouble();
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits ?? displayDecimalsFor(value),
      customPattern: symbolFirst ? _kSymbolFirstPattern : null,
    );
    return '${_sign(value, signed: signed)}${formatter.format(value.abs())}';
  }

  String formatCompact(num amount) {
    final value = amount.toDouble();
    if (!symbolFirst) {
      return NumberFormat.compactCurrency(
        locale: locale,
        symbol: symbol,
        decimalDigits: 0,
      ).format(value);
    }
    final compact = NumberFormat.compact(locale: locale).format(value.abs());
    return '${_sign(value)}$symbol\u00A0$compact';
  }

  String inputPrefix() => '$symbol ';

  /// Decimals [format] shows for [value] by default. Count-up animations use
  /// it with their target so the cents don't flicker while rolling.
  int displayDecimalsFor(num value) {
    if (inputDecimals == 0) return 0;
    final scale = math.pow(10, inputDecimals);
    return (value.abs() * scale).round() % scale == 0 ? 0 : inputDecimals;
  }

  static String _sign(double value, {bool signed = false}) {
    if (value < 0) return '-';
    return signed && value > 0 ? '+' : '';
  }
}

const supportedCurrencies = <AppCurrency>[
  AppCurrency(
    code: 'ARS',
    symbol: r'$',
    locale: 'es_AR',
    symbolFirst: true,
  ),
  AppCurrency(
    code: 'USD',
    symbol: r'$',
    locale: 'en_US',
    inputDecimals: 2,
  ),
  AppCurrency(
    code: 'EUR',
    symbol: '€',
    locale: 'es_ES',
    inputDecimals: 2,
  ),
  AppCurrency(
    code: 'BRL',
    symbol: r'R$',
    locale: 'pt_BR',
    inputDecimals: 2,
  ),
  AppCurrency(
    code: 'CLP',
    symbol: r'$',
    locale: 'es_CL',
    symbolFirst: true,
  ),
  AppCurrency(
    code: 'UYU',
    symbol: r'$U',
    locale: 'es_UY',
    symbolFirst: true,
  ),
];

AppCurrency currencyByCode(String? code) {
  return supportedCurrencies.firstWhere(
    (currency) => currency.code == code,
    orElse: () => supportedCurrencies.first,
  );
}

class CurrencyNotifier extends Notifier<AppCurrency> {
  @override
  AppCurrency build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return currencyByCode(prefs.getString(_kCurrencyKey));
  }

  Future<void> setCurrency(AppCurrency currency) async {
    state = currency;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kCurrencyKey, currency.code);
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, AppCurrency>(
  CurrencyNotifier.new,
);
