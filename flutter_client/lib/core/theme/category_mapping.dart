import 'package:flutter/material.dart';
import 'app_colors.dart';

class CategoryMapping {
  static Color getCategoryColor(String? category) {
    if (category == null) return AppColors.textSecondary;
    final lower = category.toLowerCase();

    switch (lower) {
      case 'limpieza':
      case 'cleaning':
        return AppColors.iconBlue;
      case 'hogar':
      case 'general':
      case 'residuos':
        return AppColors.iconSage;
      case 'mascotas':
      case 'pets':
        return AppColors.iconPeach;
      case 'comida':
      case 'kitchen':
      case 'cocina':
        return const Color(0xFFFB923C);
      case 'jardin':
      case 'jardín':
      case 'exterior':
      case 'outdoor':
        return const Color(0xFF84CC16);
      case 'compras':
      case 'supermarket':
        return AppColors.iconBlue;
      case 'mercadolibre':
      case 'mercado libre':
        return const Color(0xFFF6C453);
      case 'utilities':
      case 'servicios':
      case 'facturas':
        return const Color(0xFF7D94A8);
      case 'rent':
      case 'alquiler':
        return AppColors.accentPeach;
      case 'restaurants':
      case 'restaurant':
      case 'restaurante':
        return AppColors.accentOrange;
      case 'transport':
      case 'transporte':
        return const Color(0xFF38B8C8);
      case 'entertainment':
      case 'entretenimiento':
      case 'hobby':
      case 'ocio':
        return AppColors.accentPurple;
      case 'health':
      case 'salud':
        return const Color(0xFF10B981);
      case 'other':
      case 'otros gastos':
      case 'otros':
        return const Color(0xFF94A3B8);
      case 'ropa':
      case 'clothing':
      case 'indumentaria':
        return const Color(0xFF818CF8);
      case 'electronics':
      case 'tecnología':
      case 'tecnologia':
        return const Color(0xFF6366F1);
      case 'auto':
      case 'coche':
        return const Color(0xFFF87171);
      case 'finanzas':
      case 'ahorro / inversión':
      case 'ahorro / inversion':
      case 'inversión':
      case 'inversion':
      case 'savings':
        return const Color(0xFF2E8B7F);
      case 'estudio':
      case 'educación':
      case 'education':
      case 'estudio / educación':
        return AppColors.iconYellow;
      case 'urgente':
        return AppColors.error;
      case 'baño':
      case 'bano':
      case 'bathroom':
        return const Color(0xFF06B6D4);
      case 'dormitorio':
      case 'bedroom':
        return AppColors.accentPurple;
      case 'sala':
      case 'sala / espacios comunes':
      case 'espacios comunes':
        return const Color(0xFFFB923C);
      case 'mantenimiento':
      case 'mantenimiento del hogar':
      case 'bricolaje':
        return AppColors.textSecondary;
      case 'niños':
      case 'ninos':
      case 'niños / cuidado':
        return AppColors.accentOrange;
      case 'administracion':
      case 'administración':
      case 'administración del hogar':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData getCategoryMaterialIcon(String? category) {
    if (category == null) return Icons.home_rounded;
    final lower = category.toLowerCase();

    switch (lower) {
      case 'todas':
        return Icons.format_list_bulleted_rounded;
      case 'limpieza':
      case 'limpieza general':
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'hogar':
      case 'general':
        return Icons.home_rounded;
      case 'mascotas':
      case 'pets':
        return Icons.pets_rounded;
      case 'comida':
      case 'kitchen':
      case 'cocina':
        return Icons.restaurant_rounded;
      case 'jardin':
      case 'jardín':
      case 'exterior':
      case 'outdoor':
        return Icons.yard_rounded;
      case 'compras':
      case 'supermarket':
        return Icons.shopping_cart_rounded;
      case 'mercadolibre':
      case 'mercado libre':
        return Icons.storefront_rounded;
      case 'ropa':
        return Icons.checkroom_rounded;
      case 'auto':
      case 'coche':
        return Icons.directions_car_rounded;
      case 'finanzas':
      case 'savings':
        return Icons.savings_rounded;
      case 'income':
      case 'ingreso':
      case 'salary':
      case 'sueldo':
        return Icons.account_balance_wallet_rounded;
      case 'freelance':
        return Icons.laptop_mac_rounded;
      case 'ventas':
        return Icons.show_chart_rounded;
      case 'bonus':
      case 'bono':
        return Icons.workspace_premium_rounded;
      case 'settlement':
      case 'liquidacion':
      case 'liquidación':
        return Icons.sync_alt_rounded;
      case 'gift':
      case 'regalo':
        return Icons.card_giftcard_rounded;
      case 'investment':
      case 'inversión':
      case 'inversion':
        return Icons.trending_up_rounded;
      case 'crypto':
        return Icons.currency_bitcoin_rounded;
      case 'alquiler':
      case 'rent':
        return Icons.house_rounded;
      case 'utilities':
      case 'servicios':
      case 'facturas':
        return Icons.receipt_long_rounded;
      case 'entertainment':
      case 'entretenimiento':
        return Icons.movie_rounded;
      case 'restaurants':
      case 'restaurant':
      case 'restaurante':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'transporte':
        return Icons.directions_car_rounded;
      case 'estudio':
      case 'educación':
      case 'estudio / educación':
        return Icons.auto_stories_rounded;
      case 'urgente':
        return Icons.priority_high_rounded;
      case 'viajes':
        return Icons.luggage_rounded;
      case 'health':
      case 'salud':
        return Icons.local_hospital_rounded;
      case 'other':
      case 'otros gastos':
      case 'otros':
        return Icons.inventory_2_rounded;
      case 'ocio':
        return Icons.videogame_asset_rounded;
      case 'regalos':
        return Icons.card_giftcard_rounded;
      case 'baño':
      case 'bano':
      case 'bathroom':
        return Icons.shower_rounded;
      case 'dormitorio':
      case 'bedroom':
        return Icons.bed_rounded;
      case 'residuos':
        return Icons.delete_outline_rounded;
      case 'sala':
      case 'sala / espacios comunes':
        return Icons.weekend_rounded;
      case 'mantenimiento':
      case 'mantenimiento del hogar':
        return Icons.build_rounded;
      case 'niños':
      case 'ninos':
      case 'niños / cuidado':
        return Icons.child_care_rounded;
      case 'administracion':
      case 'administración':
      case 'administración del hogar':
        return Icons.assignment_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  static IconData getExpenseDisplayIcon(
    String? category, {
    String? title,
    String? description,
    String? transactionType,
    String? splitType,
  }) {
    final normalizedCategory = category?.toLowerCase().trim();
    final normalizedTitle = title?.toLowerCase().trim() ?? '';
    final normalizedDescription = description?.toLowerCase().trim() ?? '';
    final content = '$normalizedTitle $normalizedDescription';
    final normalizedType = transactionType?.toLowerCase().trim();
    final normalizedSplit = splitType?.toLowerCase().trim();

    if (normalizedSplit == 'gift' || normalizedType == 'gift') {
      return Icons.card_giftcard_rounded;
    }
    if (normalizedType == 'settlement') {
      return Icons.sync_alt_rounded;
    }
    if (normalizedType == 'income' ||
        normalizedCategory == 'income' ||
        normalizedCategory == 'ingreso' ||
        normalizedCategory == 'salary' ||
        normalizedCategory == 'sueldo' ||
        content.contains('sueldo') ||
        content.contains('salario')) {
      return Icons.account_balance_wallet_rounded;
    }
    final serviceIcon = _serviceSpecificExpenseIcon(content);
    if (serviceIcon != null) {
      return serviceIcon;
    }
    final keywordIcon = _keywordExpenseIcon(content);
    if (keywordIcon != null) {
      return keywordIcon;
    }
    if (_shouldPrioritizeExplicitExpenseCategory(normalizedCategory)) {
      return getCategoryMaterialIcon(normalizedCategory);
    }
    if (normalizedTitle.contains('sushi') ||
        normalizedTitle.contains('helado') ||
        normalizedTitle.contains('pizza') ||
        normalizedTitle.contains('cafe') ||
        normalizedTitle.contains('café') ||
        normalizedTitle.contains('restaurante')) {
      return Icons.restaurant_rounded;
    }
    if (normalizedTitle.contains('super') ||
        normalizedTitle.contains('mercado') ||
        normalizedTitle.contains('compra')) {
      return Icons.shopping_bag_rounded;
    }

    return getCategoryMaterialIcon(normalizedCategory);
  }

  static Color getExpenseDisplayColor(
    String? category, {
    String? title,
    String? transactionType,
    String? splitType,
  }) {
    final normalizedCategory = category?.toLowerCase().trim();
    final normalizedTitle = title?.toLowerCase().trim() ?? '';
    final normalizedType = transactionType?.toLowerCase().trim();
    final normalizedSplit = splitType?.toLowerCase().trim();

    if (normalizedSplit == 'gift' || normalizedType == 'gift') {
      return Colors.pinkAccent;
    }
    if (normalizedType == 'settlement') {
      return AppColors.accentBlue;
    }
    if (normalizedType == 'income' ||
        normalizedCategory == 'income' ||
        normalizedCategory == 'ingreso' ||
        normalizedCategory == 'salary' ||
        normalizedCategory == 'sueldo' ||
        normalizedTitle.contains('sueldo') ||
        normalizedTitle.contains('salario')) {
      return AppColors.success;
    }
    final serviceColor = _serviceSpecificExpenseColor(normalizedTitle);
    if (serviceColor != null) {
      return serviceColor;
    }
    final keywordColor = _keywordExpenseColor(normalizedTitle);
    if (keywordColor != null) {
      return keywordColor;
    }
    if (_shouldPrioritizeExplicitExpenseCategory(normalizedCategory)) {
      return getCategoryColor(normalizedCategory);
    }
    if (normalizedTitle.contains('sushi') ||
        normalizedTitle.contains('helado') ||
        normalizedTitle.contains('pizza') ||
        normalizedTitle.contains('cafe') ||
        normalizedTitle.contains('café') ||
        normalizedTitle.contains('restaurante')) {
      return const Color(0xFFFB923C);
    }
    if (normalizedTitle.contains('super') ||
        normalizedTitle.contains('mercado') ||
        normalizedTitle.contains('compra')) {
      return AppColors.iconBlue;
    }

    return getCategoryColor(normalizedCategory);
  }

  static IconData getSmartExpenseDisplayIcon(
    String? category, {
    String? title,
    String? description,
    String? transactionType,
    String? splitType,
  }) {
    final normalizedCategory = category?.toLowerCase().trim();
    final content =
        '${title?.toLowerCase().trim() ?? ''} ${description?.toLowerCase().trim() ?? ''}';
    final normalizedType = transactionType?.toLowerCase().trim();
    final normalizedSplit = splitType?.toLowerCase().trim();

    if (normalizedSplit == 'gift' || normalizedType == 'gift') {
      return Icons.card_giftcard_rounded;
    }
    if (normalizedType == 'settlement') {
      return Icons.sync_alt_rounded;
    }
    if (normalizedType == 'income' ||
        normalizedCategory == 'income' ||
        normalizedCategory == 'ingreso' ||
        normalizedCategory == 'salary' ||
        normalizedCategory == 'sueldo' ||
        content.contains('sueldo') ||
        content.contains('salario')) {
      return Icons.account_balance_wallet_rounded;
    }
    final serviceIcon = _serviceSpecificExpenseIcon(content);
    if (serviceIcon != null) {
      return serviceIcon;
    }
    final keywordIcon = _keywordExpenseIcon(content);
    if (keywordIcon != null) {
      return keywordIcon;
    }
    if (_shouldPrioritizeExplicitExpenseCategory(normalizedCategory)) {
      return getCategoryMaterialIcon(normalizedCategory);
    }
    if (content.contains('sushi') ||
        content.contains('ramen') ||
        content.contains('wok')) {
      return Icons.ramen_dining_rounded;
    }
    if (content.contains('pizza') ||
        content.contains('hamburguesa') ||
        content.contains('burger') ||
        content.contains('empanada')) {
      return Icons.lunch_dining_rounded;
    }
    if (content.contains('helado') ||
        content.contains('postre') ||
        content.contains('torta') ||
        content.contains('cafe') ||
        content.contains('café')) {
      return Icons.icecream_rounded;
    }
    if (content.contains('restaurante') ||
        content.contains('cena') ||
        content.contains('almuerzo') ||
        content.contains('desayuno')) {
      return Icons.restaurant_rounded;
    }
    if (content.contains('super') ||
        content.contains('mercado') ||
        content.contains('compra') ||
        content.contains('carrefour') ||
        content.contains('coto') ||
        content.contains('jumbo')) {
      return Icons.shopping_bag_rounded;
    }
    if (content.contains('uber') ||
        content.contains('cabify') ||
        content.contains('taxi') ||
        content.contains('subte') ||
        content.contains('colectivo') ||
        content.contains('nafta') ||
        content.contains('combustible')) {
      return Icons.directions_car_filled_rounded;
    }
    if (content.contains('farmacia') ||
        content.contains('ibuprofeno') ||
        content.contains('paracetamol') ||
        content.contains('medicamento')) {
      return Icons.local_pharmacy_rounded;
    }

    return getCategoryMaterialIcon(normalizedCategory);
  }

  static Color getSmartExpenseDisplayColor(
    String? category, {
    String? title,
    String? description,
    String? transactionType,
    String? splitType,
  }) {
    final normalizedCategory = category?.toLowerCase().trim();
    final content =
        '${title?.toLowerCase().trim() ?? ''} ${description?.toLowerCase().trim() ?? ''}';
    final normalizedType = transactionType?.toLowerCase().trim();
    final normalizedSplit = splitType?.toLowerCase().trim();

    if (normalizedSplit == 'gift' || normalizedType == 'gift') {
      return Colors.pinkAccent;
    }
    if (normalizedType == 'settlement') {
      return AppColors.accentBlue;
    }
    if (normalizedType == 'income' ||
        normalizedCategory == 'income' ||
        normalizedCategory == 'ingreso' ||
        normalizedCategory == 'salary' ||
        normalizedCategory == 'sueldo' ||
        content.contains('sueldo') ||
        content.contains('salario')) {
      return AppColors.success;
    }
    final serviceColor = _serviceSpecificExpenseColor(content);
    if (serviceColor != null) {
      return serviceColor;
    }
    final keywordColor = _keywordExpenseColor(content);
    if (keywordColor != null) {
      return keywordColor;
    }
    if (_shouldPrioritizeExplicitExpenseCategory(normalizedCategory)) {
      return getCategoryColor(normalizedCategory);
    }
    if (content.contains('sushi') ||
        content.contains('ramen') ||
        content.contains('wok')) {
      return const Color(0xFFF97316);
    }
    if (content.contains('pizza') ||
        content.contains('hamburguesa') ||
        content.contains('burger') ||
        content.contains('empanada')) {
      return const Color(0xFFEF6C3E);
    }
    if (content.contains('helado') ||
        content.contains('postre') ||
        content.contains('torta') ||
        content.contains('cafe') ||
        content.contains('café')) {
      return const Color(0xFFEC4899);
    }
    if (content.contains('restaurante') ||
        content.contains('cena') ||
        content.contains('almuerzo') ||
        content.contains('desayuno')) {
      return const Color(0xFFFB923C);
    }
    if (content.contains('super') ||
        content.contains('mercado') ||
        content.contains('compra') ||
        content.contains('carrefour') ||
        content.contains('coto') ||
        content.contains('jumbo')) {
      return AppColors.iconBlue;
    }
    if (content.contains('uber') ||
        content.contains('cabify') ||
        content.contains('taxi') ||
        content.contains('subte') ||
        content.contains('colectivo') ||
        content.contains('nafta') ||
        content.contains('combustible')) {
      return const Color(0xFF6366F1);
    }
    if (content.contains('farmacia') ||
        content.contains('ibuprofeno') ||
        content.contains('paracetamol') ||
        content.contains('medicamento')) {
      return const Color(0xFF10B981);
    }

    return getCategoryColor(normalizedCategory);
  }

  static const Map<String, String> categoryIcons = {
    'cleaning': '🧹',
    'limpieza': '🧹',
    'kitchen': '🍽️',
    'cocina': '🍽️',
    'bedroom': '🛌',
    'dormitorio': '🛌',
    'bathroom': '🚿',
    'baño': '🚿',
    'general': '🏠',
    'hogar': '🏠',
    'pets': '🐾',
    'mascotas': '🐾',
    'exterior': '🌿',
    'exterior / jardín': '🌿',
    'jardin': '🌿',
    'jardín': '🌿',
    'garden': '🌿',
    'compras': '🛒',
    'compras / organización': '🛒',
    'supermarket': '🛒',
    'mercadolibre': '🛍️',
    'mercado libre': '🛍️',
    'ropa': '👕',
    'residuos': '🗑️',
    'basura': '🗑️',
    'basura / reciclaje': '🗑️',
    'sala': '🛋️',
    'espacios comunes': '🛋️',
    'mantenimiento': '🔧',
    'mantenimiento del hogar': '🔧',
    'niños': '👶',
    'niños / cuidado': '👶',
    'administracion': '📋',
    'administración del hogar': '📋',
    'urgente': '🚨',
    'finanzas': '💰',
    'savings': '🏦',
    'income': '🚀',
    'settlement': '🤝',
    'salary': '🏦',
    'sueldo': '🏦',
    'freelance': '💻',
    'ventas': '📊',
    'gift': '🎁',
    'regalo': '🎁',
    'bonus': '🎊',
    'bono': '🎊',
    'reembolso': '🔙',
    'investment': '📈',
    'inversión': '📈',
    'alquiler': '🏠',
    'premium': '💎',
    'crypto': '🪙',
    'pension': '👴',
    'jubilación': '👴',
    'prestamo': '💵',
    'rent': '🏠',
    'utilities': '💡',
    'restaurants': '🍽️',
    'transport': '🚙',
    'health': '🏥',
    'other': '📦',
    'varios': '📦',
  };

  static const Map<String, String> categoryNames = {
    'cleaning': 'Limpieza',
    'limpieza': 'Limpieza',
    'kitchen': 'Cocina',
    'cocina': 'Cocina',
    'bedroom': 'Dormitorio',
    'dormitorio': 'Dormitorio',
    'bathroom': 'Baño',
    'baño': 'Baño',
    'general': 'Hogar',
    'hogar': 'Hogar',
    'pets': 'Mascotas',
    'mascotas': 'Mascotas',
    'outdoor': 'Jardín',
    'exterior': 'Exterior',
    'garden': 'Jardín',
    'jardin': 'Jardín',
    'jardín': 'Jardín',
    'supermarket': 'Supermercado',
    'mercadolibre': 'Compras online',
    'mercado libre': 'Compras online',
    'compras': 'Compras',
    'ropa': 'Ropa',
    'residuos': 'Basura / Reciclaje',
    'basura': 'Basura / Reciclaje',
    'basura / reciclaje': 'Basura / Reciclaje',
    'sala': 'Espacios Comunes',
    'espacios comunes': 'Espacios Comunes',
    'mantenimiento': 'Mantenimiento del Hogar',
    'mantenimiento del hogar': 'Mantenimiento del Hogar',
    'niños': 'Niños / Cuidado',
    'niños / cuidado': 'Niños / Cuidado',
    'administracion': 'Administración del Hogar',
    'administración del hogar': 'Administración del Hogar',
    'finanzas': 'Finanzas',
    'savings': 'Ahorro',
    'income': 'Ingreso',
    'settlement': 'Liquidación de balance',
    'rent': 'Alquiler y hogar',
    'utilities': 'Servicios',
    'restaurants': 'Salidas y comidas',
    'transport': 'Transporte',
    'health': 'Salud',
    'salary': 'Sueldo',
    'sueldo': 'Sueldo',
    'freelance': 'Freelance',
    'ventas': 'Ventas',
    'gift': 'Regalo',
    'regalo': 'Regalo',
    'bonus': 'Bono / Premio',
    'bono': 'Bono / Premio',
    'reembolso': 'Reembolso',
    'investment': 'Inversión',
    'inversión': 'Inversión',
    'alquiler_premium': 'Renta',
    'pension': 'Pensub/Jubilación',
    'crypto': 'Cripto / Inversión',
    'prestamo': 'Préstamo',
    'entertainment': 'Ocio y planes',
    'other': 'Otros',
  };

  static const Map<String, String> safeCategoryIcons = {
    'cleaning': '\u{1F9F9}',
    'limpieza': '\u{1F9F9}',
    'kitchen': '\u{1F37D}\u{FE0F}',
    'cocina': '\u{1F37D}\u{FE0F}',
    'bedroom': '\u{1F6CC}',
    'dormitorio': '\u{1F6CC}',
    'bathroom': '\u{1F6BF}',
    'baño': '\u{1F6BF}',
    'bano': '\u{1F6BF}',
    'general': '\u{1F3E0}',
    'hogar': '\u{1F3E0}',
    'pets': '\u{1F43E}',
    'mascotas': '\u{1F43E}',
    'outdoor': '\u{1F33F}',
    'exterior': '\u{1F33F}',
    'exterior / jardín': '\u{1F33F}',
    'exterior / jardin': '\u{1F33F}',
    'garden': '\u{1F33F}',
    'jardin': '\u{1F33F}',
    'jardín': '\u{1F33F}',
    'compras': '\u{1F6D2}',
    'compras / organización': '\u{1F6D2}',
    'compras / organizacion': '\u{1F6D2}',
    'supermarket': '\u{1F6D2}',
    'mercadolibre': '\u{1F6CD}\u{FE0F}',
    'mercado libre': '\u{1F6CD}\u{FE0F}',
    'ropa': '\u{1F455}',
    'residuos': '\u{1F5D1}\u{FE0F}',
    'basura': '\u{1F5D1}\u{FE0F}',
    'basura / reciclaje': '\u{1F5D1}\u{FE0F}',
    'sala': '\u{1F6CB}\u{FE0F}',
    'espacios comunes': '\u{1F6CB}\u{FE0F}',
    'mantenimiento': '\u{1F527}',
    'mantenimiento del hogar': '\u{1F527}',
    'niños': '\u{1F476}',
    'ninos': '\u{1F476}',
    'niños / cuidado': '\u{1F476}',
    'ninos / cuidado': '\u{1F476}',
    'administracion': '\u{1F4CB}',
    'administración del hogar': '\u{1F4CB}',
    'administracion del hogar': '\u{1F4CB}',
    'urgente': '\u{1F6A8}',
    'finanzas': '\u{1F4B0}',
    'savings': '\u{1F3E6}',
    'income': '\u{1F680}',
    'settlement': '\u{1F91D}',
    'salary': '\u{1F3E6}',
    'sueldo': '\u{1F3E6}',
    'freelance': '\u{1F4BB}',
    'ventas': '\u{1F4CA}',
    'gift': '\u{1F381}',
    'regalo': '\u{1F381}',
    'bonus': '\u{1F38A}',
    'bono': '\u{1F38A}',
    'reembolso': '\u{1F519}',
    'investment': '\u{1F4C8}',
    'inversión': '\u{1F4C8}',
    'inversion': '\u{1F4C8}',
    'alquiler': '\u{1F3E0}',
    'premium': '\u{1F48E}',
    'crypto': '\u{1FA99}',
    'pension': '\u{1F474}',
    'jubilación': '\u{1F474}',
    'jubilacion': '\u{1F474}',
    'prestamo': '\u{1F4B5}',
    'rent': '\u{1F3E0}',
    'utilities': '\u{1F4A1}',
    'restaurants': '\u{1F37D}\u{FE0F}',
    'transport': '\u{1F699}',
    'health': '\u{1F3E5}',
    'other': '\u{1F4E6}',
    'varios': '\u{1F4E6}',
  };

  static String getMonthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  static String normaliseCategory(String? category) {
    if (category == null || category.trim().isEmpty) return 'general';
    final lower = category.toLowerCase().trim();
    if (lower == 'cleaning') return 'limpieza';
    if (lower == 'kitchen' ||
        lower == 'comida' ||
        lower == 'cocina' ||
        lower == 'restaurant' ||
        lower == 'restaurants' ||
        lower == 'restaurante') {
      return 'cocina';
    }
    if (lower == 'bathroom' || lower == 'baño') return 'bano';
    if (lower == 'bedroom') return 'dormitorio';
    if (lower == 'pets') return 'mascotas';
    if (lower == 'outdoor' ||
        lower == 'garden' ||
        lower == 'jardín' ||
        lower == 'jardin') {
      return 'jardin';
    }
    if (lower == 'supermarket') {
      return 'compras';
    }
    if (lower == 'savings') {
      return 'finanzas';
    }
    if (lower == 'niños' ||
        lower == 'niño' ||
        lower == 'ninos' ||
        lower == 'niña') {
      return 'ninos';
    }
    return lower;
  }

  static bool _shouldPrioritizeExplicitExpenseCategory(String? category) {
    switch (category) {
      case 'supermarket':
      case 'compras':
      case 'mercadolibre':
      case 'mercado libre':
      case 'utilities':
      case 'servicios':
      case 'facturas':
      case 'rent':
      case 'alquiler':
      case 'restaurants':
      case 'restaurant':
      case 'restaurante':
      case 'transport':
      case 'transporte':
      case 'entertainment':
      case 'entretenimiento':
      case 'health':
      case 'salud':
      case 'other':
      case 'otros gastos':
      case 'otros':
      case 'finanzas':
      case 'savings':
      case 'investment':
      case 'inversión':
      case 'inversion':
      case 'settlement':
      case 'liquidación':
      case 'liquidacion':
        return true;
      default:
        return false;
    }
  }

  static IconData? _serviceSpecificExpenseIcon(String content) {
    if (content.isEmpty) return null;

    if (_containsAny(content, const [
      'gas',
      'metrogas',
      'natural gas',
      'gas natural',
      'garrafa',
    ])) {
      return Icons.local_fire_department_rounded;
    }
    if (_containsAny(content, const [
      'luz',
      'electricidad',
      'edenor',
      'edesur',
      'energia',
      'energía',
      'electric',
    ])) {
      return Icons.bolt_rounded;
    }
    if (_containsAny(content, const [
      'internet',
      'wifi',
      'wi-fi',
      'fibra',
      'telecentro',
      'personal flow',
    ])) {
      return Icons.wifi_rounded;
    }
    if (_containsAny(content, const [
      'agua',
      'aysa',
      'water',
    ])) {
      return Icons.water_drop_rounded;
    }
    if (_containsAny(content, const [
      'telefono',
      'teléfono',
      'celular',
      'phone',
      'mobile',
      'claro',
      'movistar',
    ])) {
      return Icons.smartphone_rounded;
    }
    if (_containsAny(content, const [
      'expensas',
      'consorcio',
      'administracion',
      'administración',
    ])) {
      return Icons.apartment_rounded;
    }
    if (_containsAny(content, const [
      'alquiler',
      'rent',
      'inmobiliaria',
    ])) {
      return Icons.house_rounded;
    }
    if (_containsAny(content, const [
      'netflix',
      'spotify',
      'disney',
      'hbo',
      'hbo max',
      'prime video',
      'youtube premium',
      'suscripcion',
      'suscripción',
      'streaming',
    ])) {
      return Icons.play_circle_rounded;
    }
    if (_containsAny(content, const [
      'seguro',
      'insurance',
      'obra social',
      'prepaga',
    ])) {
      return Icons.health_and_safety_rounded;
    }

    return null;
  }

  static Color? _serviceSpecificExpenseColor(String content) {
    if (content.isEmpty) return null;

    if (_containsAny(content, const [
      'gas',
      'metrogas',
      'natural gas',
      'gas natural',
      'garrafa',
    ])) {
      return const Color(0xFFF97316);
    }
    if (_containsAny(content, const [
      'luz',
      'electricidad',
      'edenor',
      'edesur',
      'energia',
      'energía',
      'electric',
    ])) {
      return const Color(0xFFF6B21A);
    }
    if (_containsAny(content, const [
      'internet',
      'wifi',
      'wi-fi',
      'fibra',
      'telecentro',
      'personal flow',
    ])) {
      return const Color(0xFF3B82F6);
    }
    if (_containsAny(content, const [
      'agua',
      'aysa',
      'water',
    ])) {
      return const Color(0xFF06B6D4);
    }
    if (_containsAny(content, const [
      'telefono',
      'teléfono',
      'celular',
      'phone',
      'mobile',
      'claro',
      'movistar',
    ])) {
      return const Color(0xFF8B5CF6);
    }
    if (_containsAny(content, const [
      'expensas',
      'consorcio',
      'administracion',
      'administración',
    ])) {
      return const Color(0xFF64748B);
    }
    if (_containsAny(content, const [
      'alquiler',
      'rent',
      'inmobiliaria',
    ])) {
      return AppColors.accentPeach;
    }
    if (_containsAny(content, const [
      'netflix',
      'spotify',
      'disney',
      'hbo',
      'hbo max',
      'prime video',
      'youtube premium',
      'suscripcion',
      'suscripción',
      'streaming',
    ])) {
      return const Color(0xFFE11D48);
    }
    if (_containsAny(content, const [
      'seguro',
      'insurance',
      'obra social',
      'prepaga',
    ])) {
      return const Color(0xFF10B981);
    }

    return null;
  }

  static IconData? _keywordExpenseIcon(String content) {
    if (content.isEmpty) return null;

    if (_containsAny(content, const [
      'sushi',
      'ramen',
      'wok',
      'poke',
    ])) {
      return Icons.ramen_dining_rounded;
    }
    if (_containsAny(content, const [
      'pizza',
      'hamburguesa',
      'burger',
      'empanada',
      'sandwich',
      'sándwich',
      'mcdonald',
      'burger king',
      'mostaza',
    ])) {
      return Icons.lunch_dining_rounded;
    }
    if (_containsAny(content, const [
      'helado',
      'postre',
      'torta',
      'cafe',
      'café',
      'medialuna',
      'panaderia',
      'panadería',
      'pasteleria',
      'pastelería',
    ])) {
      return Icons.icecream_rounded;
    }
    if (_containsAny(content, const [
      'restaurante',
      'restaurant',
      'cena',
      'almuerzo',
      'desayuno',
      'bar',
      'bistro',
      'bistró',
    ])) {
      return Icons.restaurant_rounded;
    }
    if (_containsAny(content, const [
      'super',
      'mercado',
      'compra',
      'carrefour',
      'coto',
      'jumbo',
      'dia',
      'disco',
      'vea',
    ])) {
      return Icons.shopping_bag_rounded;
    }
    if (_containsAny(content, const [
      'farmacia',
      'farmacity',
      'ibuprofeno',
      'paracetamol',
      'medicamento',
      'remedio',
    ])) {
      return Icons.local_pharmacy_rounded;
    }
    if (_containsAny(content, const [
      'uber',
      'cabify',
      'taxi',
      'subte',
      'colectivo',
      'nafta',
      'combustible',
      'estacionamiento',
      'parking',
      'peaje',
      'shell',
      'ypf',
      'axion',
    ])) {
      return Icons.directions_car_filled_rounded;
    }
    if (_containsAny(content, const [
      'veterinaria',
      'vet',
      'petshop',
      'pet shop',
      'balanceado',
      'alimento perro',
      'alimento gato',
    ])) {
      return Icons.pets_rounded;
    }
    if (_containsAny(content, const [
      'gym',
      'gimnasio',
      'entrenamiento',
      'crossfit',
      'pilates',
      'yoga',
    ])) {
      return Icons.fitness_center_rounded;
    }
    if (_containsAny(content, const [
      'ropa',
      'remera',
      'pantalon',
      'pantalón',
      'zapatilla',
      'zapatillas',
      'campera',
      'vestido',
    ])) {
      return Icons.checkroom_rounded;
    }
    if (_containsAny(content, const [
      'ferreteria',
      'ferretería',
      'herramienta',
      'reparacion',
      'reparación',
      'pintura',
      'electricista',
      'plomero',
      'cerrajero',
    ])) {
      return Icons.handyman_rounded;
    }
    if (_containsAny(content, const [
      'colegio',
      'escuela',
      'curso',
      'universidad',
      'libro',
      'clase',
      'matricula',
      'matrícula',
    ])) {
      return Icons.school_rounded;
    }
    if (_containsAny(content, const [
      'cine',
      'teatro',
      'show',
      'concierto',
      'entrada',
      'steam',
      'playstation',
      'xbox',
      'nintendo',
    ])) {
      return Icons.movie_rounded;
    }
    if (_containsAny(content, const [
      'hotel',
      'vuelo',
      'pasaje',
      'aerolineas',
      'aerolíneas',
      'airbnb',
      'hostel',
      'viaje',
      'vacaciones',
    ])) {
      return Icons.luggage_rounded;
    }
    if (_containsAny(content, const [
      'juguete',
      'guarderia',
      'guardería',
      'pañal',
      'panal',
      'leche maternizada',
      'jardin maternal',
      'jardín maternal',
    ])) {
      return Icons.child_care_rounded;
    }

    return null;
  }

  static Color? _keywordExpenseColor(String content) {
    if (content.isEmpty) return null;

    if (_containsAny(content, const [
      'sushi',
      'ramen',
      'wok',
      'poke',
    ])) {
      return const Color(0xFFF97316);
    }
    if (_containsAny(content, const [
      'pizza',
      'hamburguesa',
      'burger',
      'empanada',
      'sandwich',
      'sándwich',
      'mcdonald',
      'burger king',
      'mostaza',
    ])) {
      return const Color(0xFFEF6C3E);
    }
    if (_containsAny(content, const [
      'helado',
      'postre',
      'torta',
      'cafe',
      'café',
      'medialuna',
      'panaderia',
      'panadería',
      'pasteleria',
      'pastelería',
    ])) {
      return const Color(0xFFEC4899);
    }
    if (_containsAny(content, const [
      'restaurante',
      'restaurant',
      'cena',
      'almuerzo',
      'desayuno',
      'bar',
      'bistro',
      'bistró',
    ])) {
      return const Color(0xFFFB923C);
    }
    if (_containsAny(content, const [
      'super',
      'mercado',
      'compra',
      'carrefour',
      'coto',
      'jumbo',
      'dia',
      'disco',
      'vea',
    ])) {
      return AppColors.iconBlue;
    }
    if (_containsAny(content, const [
      'farmacia',
      'farmacity',
      'ibuprofeno',
      'paracetamol',
      'medicamento',
      'remedio',
    ])) {
      return const Color(0xFF10B981);
    }
    if (_containsAny(content, const [
      'uber',
      'cabify',
      'taxi',
      'subte',
      'colectivo',
      'nafta',
      'combustible',
      'estacionamiento',
      'parking',
      'peaje',
      'shell',
      'ypf',
      'axion',
    ])) {
      return const Color(0xFF6366F1);
    }
    if (_containsAny(content, const [
      'veterinaria',
      'vet',
      'petshop',
      'pet shop',
      'balanceado',
      'alimento perro',
      'alimento gato',
    ])) {
      return const Color(0xFFF59E0B);
    }
    if (_containsAny(content, const [
      'gym',
      'gimnasio',
      'entrenamiento',
      'crossfit',
      'pilates',
      'yoga',
    ])) {
      return const Color(0xFF8B5CF6);
    }
    if (_containsAny(content, const [
      'ropa',
      'remera',
      'pantalon',
      'pantalón',
      'zapatilla',
      'zapatillas',
      'campera',
      'vestido',
    ])) {
      return const Color(0xFF818CF8);
    }
    if (_containsAny(content, const [
      'ferreteria',
      'ferretería',
      'herramienta',
      'reparacion',
      'reparación',
      'pintura',
      'electricista',
      'plomero',
      'cerrajero',
    ])) {
      return const Color(0xFF64748B);
    }
    if (_containsAny(content, const [
      'colegio',
      'escuela',
      'curso',
      'universidad',
      'libro',
      'clase',
      'matricula',
      'matrícula',
    ])) {
      return const Color(0xFFEAB308);
    }
    if (_containsAny(content, const [
      'cine',
      'teatro',
      'show',
      'concierto',
      'entrada',
      'steam',
      'playstation',
      'xbox',
      'nintendo',
    ])) {
      return AppColors.accentPurple;
    }
    if (_containsAny(content, const [
      'hotel',
      'vuelo',
      'pasaje',
      'aerolineas',
      'aerolíneas',
      'airbnb',
      'hostel',
      'viaje',
      'vacaciones',
    ])) {
      return const Color(0xFF14B8A6);
    }
    if (_containsAny(content, const [
      'juguete',
      'guarderia',
      'guardería',
      'pañal',
      'panal',
      'leche maternizada',
      'jardin maternal',
      'jardín maternal',
    ])) {
      return const Color(0xFFF97316);
    }

    return null;
  }

  static bool _containsAny(String content, List<String> terms) {
    for (final term in terms) {
      if (_containsTerm(content, term)) {
        return true;
      }
    }
    return false;
  }

  static bool _containsTerm(String content, String term) {
    final escapedTerm = RegExp.escape(term);
    final pattern = RegExp(
      '(^|[^a-z0-9áéíóúüñ])$escapedTerm([^a-z0-9áéíóúüñ]|\$)',
      caseSensitive: false,
    );
    return pattern.hasMatch(content);
  }
}
