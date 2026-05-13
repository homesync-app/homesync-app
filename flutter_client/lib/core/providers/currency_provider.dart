import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/theme_provider.dart'
    show sharedPreferencesProvider;
import 'package:intl/intl.dart';

const _kCurrencyKey = 'app_currency_code';

class AppCurrency {
  final String code;
  final String symbol;
  final String locale;
  final String spanishName;
  final String englishName;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.locale,
    required this.spanishName,
    required this.englishName,
  });

  String label(String languageCode) {
    final name = languageCode == 'en' ? englishName : spanishName;
    return '$code · $name';
  }

  String format(
    num amount, {
    bool signed = false,
    int decimalDigits = 0,
  }) {
    final value = amount.toDouble();
    final sign = signed && value > 0
        ? '+'
        : value < 0
            ? '-'
            : '';
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return '$sign${formatter.format(value.abs())}';
  }

  String formatCompact(num amount) {
    return NumberFormat.compactCurrency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    ).format(amount);
  }

  String inputPrefix() => '$symbol ';
}

const supportedCurrencies = <AppCurrency>[
  AppCurrency(
    code: 'ARS',
    symbol: r'$',
    locale: 'es_AR',
    spanishName: 'Peso argentino',
    englishName: 'Argentine peso',
  ),
  AppCurrency(
    code: 'USD',
    symbol: r'$',
    locale: 'en_US',
    spanishName: 'Dolar estadounidense',
    englishName: 'US dollar',
  ),
  AppCurrency(
    code: 'EUR',
    symbol: '€',
    locale: 'es_ES',
    spanishName: 'Euro',
    englishName: 'Euro',
  ),
  AppCurrency(
    code: 'BRL',
    symbol: r'R$',
    locale: 'pt_BR',
    spanishName: 'Real brasileno',
    englishName: 'Brazilian real',
  ),
  AppCurrency(
    code: 'CLP',
    symbol: r'$',
    locale: 'es_CL',
    spanishName: 'Peso chileno',
    englishName: 'Chilean peso',
  ),
  AppCurrency(
    code: 'UYU',
    symbol: r'$U',
    locale: 'es_UY',
    spanishName: 'Peso uruguayo',
    englishName: 'Uruguayan peso',
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
