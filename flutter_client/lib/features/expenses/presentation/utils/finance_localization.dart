import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_data.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

String localizedFinanceCategoryName(
  AppLocalizations t,
  String? categoryId, {
  String? fallback,
  bool isIncome = false,
}) {
  final normalized = _normalizeFinanceToken(categoryId);
  if (normalized.isEmpty) {
    return fallback ?? t.expensesFormCategoryOtherExpenses;
  }

  if (isIncome || _incomeCategoryIds.contains(normalized)) {
    return localizedIncomeCategoryName(t, normalized);
  }

  final expenseCategoryId = _categoryAliases[normalized] ?? normalized;
  return localizedExpenseCategoryName(t, expenseCategoryId);
}

String localizedFinanceTitle(
  AppLocalizations t, {
  required String title,
  String? titleKey,
  String? category,
  String? transactionType,
}) {
  final key = titleKey ??
      financeTitleKeyFor(
        title,
        category: category,
        transactionType: transactionType,
      );

  if (key != null) {
    switch (key) {
      case 'financeTitleSupermarket':
        return t.financeTitleSupermarket;
      case 'financeTitleOnlineShopping':
        return t.financeTitleOnlineShopping;
      case 'financeTitleBalanceSettlement':
        return t.financeTitleBalanceSettlement;
      case 'financeTitlePartnerSettlement':
        return t.financeTitlePartnerSettlement;
      case 'financeTitleSalary':
        return t.financeTitleSalary;
      case 'financeTitleRent':
        return t.financeTitleRent;
      case 'financeTitleBuildingFees':
        return t.financeTitleBuildingFees;
      case 'financeTitleGas':
        return t.financeTitleGas;
      case 'financeTitleElectricity':
        return t.financeTitleElectricity;
      case 'financeTitleWater':
        return t.financeTitleWater;
      case 'financeTitleInternet':
        return t.financeTitleInternet;
      case 'financeTitleNetflix':
        return t.financeTitleNetflix;
      case 'financeTitleMovies':
        return t.financeTitleMovies;
      case 'financeTitleInsurance':
        return t.financeTitleInsurance;
      case 'financeTitlePhone':
        return t.financeTitlePhone;
    }
  }

  final trimmed = title.trim();
  if (trimmed.isEmpty) {
    return localizedFinanceCategoryName(t, category);
  }
  return trimmed;
}

String? financeTitleKeyFor(
  String? title, {
  String? category,
  String? transactionType,
}) {
  final normalized = _normalizeFinanceToken(title);
  final normalizedCategory = _normalizeFinanceToken(category);
  final normalizedType = _normalizeFinanceToken(transactionType);

  if (normalized.isEmpty) return null;

  if (normalizedType == 'settlement' ||
      normalized == 'liquidacion de balance' ||
      normalized == 'liquidacion de saldo' ||
      normalized == 'liquidacion de deuda') {
    return 'financeTitleBalanceSettlement';
  }

  if (normalized == 'liquidacion de pareja') {
    return 'financeTitlePartnerSettlement';
  }

  if (normalized == normalizedCategory ||
      _categoryAliases[normalized] != null ||
      CategoryMapping.categoryNames.containsKey(normalized)) {
    return null;
  }

  if (normalizedCategory == 'supermarket' ||
      normalizedCategory == 'groceries') {
    if (normalized.contains('supermerc') ||
        normalized.contains('supermarket') ||
        normalized.contains('compras del') ||
        normalized.contains('compra del') ||
        normalized.contains('compra de supermercado')) {
      return 'financeTitleSupermarket';
    }
  }

  if (normalizedCategory == 'mercadolibre' ||
      normalized == 'mercadolibre' ||
      normalized == 'mercado libre' ||
      normalized.contains('compras online')) {
    return 'financeTitleOnlineShopping';
  }

  switch (normalized) {
    case 'sueldo':
    case 'salario':
    case 'salary':
      return 'financeTitleSalary';
    case 'alquiler':
    case 'alquler':
    case 'rent':
      return 'financeTitleRent';
    case 'expensas':
    case 'building fees':
      return 'financeTitleBuildingFees';
    case 'gas':
      return 'financeTitleGas';
    case 'luz':
    case 'electricidad':
    case 'electricity':
      return 'financeTitleElectricity';
    case 'agua':
    case 'water':
      return 'financeTitleWater';
    case 'internet':
      return 'financeTitleInternet';
    case 'netflix':
      return 'financeTitleNetflix';
    case 'pelis':
    case 'peliculas':
    case 'movies':
      return 'financeTitleMovies';
    case 'seguro':
    case 'srguro':
    case 'insurance':
      return 'financeTitleInsurance';
    case 'celu':
    case 'celular':
    case 'celu blas':
    case 'phone':
      return 'financeTitlePhone';
  }

  return null;
}

String financeTitleKeyForSave(String title, {String? category, String? type}) {
  return financeTitleKeyFor(title, category: category, transactionType: type) ??
      '';
}

const _incomeCategoryIds = {
  'salary',
  'freelance',
  'ventas',
  'bonus',
  'reembolso',
  'gift',
  'investment',
  'income',
};

const _categoryAliases = {
  'groceries': 'supermarket',
  'shopping': 'supermarket',
  'compras': 'supermarket',
  'mercado libre': 'mercadolibre',
  'servicios': 'utilities',
  'facturas': 'utilities',
  'alquiler': 'rent',
  'restaurante': 'restaurants',
  'restaurant': 'restaurants',
  'transporte': 'transport',
  'ocio': 'entertainment',
  'salud': 'health',
  'finanzas': 'finanzas',
  'savings': 'finanzas',
  'liquidacion': 'settlement',
  'liquidacion de balance': 'settlement',
};

String _normalizeFinanceToken(String? value) {
  final lower = (value ?? '').trim().toLowerCase();
  if (lower.isEmpty) return '';

  return lower
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'\s+'), ' ');
}
