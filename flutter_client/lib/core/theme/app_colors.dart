import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Stitch Design - Warm Scandi Theme)
  static const Color primary = Color(0xFFEE652B);
  static const Color primaryLight = Color(0xFFFFF0EA);
  static const Color primaryDark = Color(0xFFD85A23);

  // Backgrounds
  static const Color background = Color(0xFFFFFCF9);
  static const Color backgroundDark = Color(0xFF1B1716);
  static const Color surface = Color(0xFFFFF8F2);
  static const Color surfaceDark = Color(0xFF26211F);
  static const Color cardDark = Color(0xFF2F2927);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color elevatedSurface = Color(0xFFFDF6EF);
  static const Color elevatedSurfaceDark = Color(0xFF342E2B);
  static const Color navSurface = Color(0xFFFFFBF7);
  static const Color navSurfaceDark = Color(0xFF211C1A);

  // Accent Colors
  static const Color sage = Color(0xFF84A59D);
  static const Color accentGold = Color(0xFFFFBD3D);
  static const Color accentTeal = sage;
  static const Color accentRed = Color(0xFFE57373);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF9575CD);
  static const Color accentPeach = Color(0xFFE88D67);
  static const Color accentOrange = Color(0xFFFF8A65);
  static const Color accentYellow = Color(0xFFD4C550);

  // Icon Palette (Mockup specific)
  static const Color iconPeach = Color(0xFFE88D67);
  static const Color iconSage = Color(0xFF6B8E85);
  static const Color iconBlue = Color(0xFF6B9FE8);
  static const Color iconYellow = Color(0xFFD4C550);
  static const Color iconRed = Color(0xFFE57373);
  static const Color iconGreen = Color(0xFF22C55E);

  // Neutral Colors
  static const Color textPrimary = Color(0xFF4A4443);
  static const Color textSecondary = Color(0xFF8E8480);
  static const Color textMuted = Color(0xFFB2AAA6);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color success = accentGreen;
  static const Color error = accentRed;
  static const Color warning = accentGold;
  static const Color info = accentTeal;
  static const Color accent = primary;

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static const Color divider = Color(0xFFF0E4D9);
  static const Color border = Color(0xFFF0E4D9);
  static const Color cardBorder = border;
  static const Color inputBorder = border;
  static const Color surfaceVariant = Color(0xFFFFF4EB);
  static const Color shadow = Color(0x124A4443);
  static const Color shadowBase = Color(0xFF4A4443);
  static const Color cardGhostBorderLight = Color(0x144A4443);
  static const Color cardGhostBorderDark = Color(0x332E2B45);

  static Color get infoLight => info.withValues(alpha: 0.12);
  static Color get successLight => success.withValues(alpha: 0.12);
  static Color get errorLight => error.withValues(alpha: 0.12);
  static Color get warningLight => warning.withValues(alpha: 0.12);

  // Glassmorphism effects
  static const Color glassWhite = Color(0xB3FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFFEE652B),
    Color(0xFFFF8A65),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF84A59D),
    Color(0xFFA8C4BF),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFFFFFCF9),
    Color(0xFFFFF5EE),
  ];

  // Category Colors
  static const Color categoryCleaning = Color(0xFFEE652B);
  static const Color categoryKitchen = Color(0xFFFBBF24);
  static const Color categoryBedroom = Color(0xFF7D6EF2);
  static const Color categoryBathroom = Color(0xFF84A59D);
  static const Color categoryGeneral = Color(0xFF64748B);
  static const Color categoryPets = Color(0xFFFF8A65);
  static const Color categoryOutdoor = Color(0xFF84A59D);
  static const Color categorySupermarket = Color(0xFF3B82F6);
  static const Color categoryUrgent = Color(0xFFEF4444);

  static Color getCategoryColor(String? category) {
    if (category == null) return textSecondary;
    final lower = category.toLowerCase();

    switch (lower) {
      case 'limpieza':
      case 'cleaning':
        return iconBlue;
      case 'hogar':
      case 'general':
      case 'residuos':
        return iconSage;
      case 'mascotas':
      case 'pets':
        return iconPeach;
      case 'comida':
      case 'kitchen':
      case 'cocina':
        return const Color(0xFFFB923C); // Orange
      case 'jardin':
      case 'jardín':
      case 'exterior':
      case 'outdoor':
        return const Color(0xFF84CC16); // Lime
      case 'compras':
      case 'supermarket':
        return iconBlue;
      case 'mercadolibre':
      case 'mercado libre':
        return accentBlue;
      case 'utilities':
      case 'servicios':
      case 'facturas':
        return iconYellow;
      case 'rent':
      case 'alquiler':
        return accentPeach;
      case 'restaurants':
      case 'restaurant':
      case 'restaurante':
        return accentOrange;
      case 'transport':
      case 'transporte':
        return const Color(0xFF6366F1);
      case 'entertainment':
      case 'hobby':
      case 'ocio':
        return accentPurple;
      case 'health':
      case 'salud':
        return const Color(0xFF10B981);
      case 'ropa':
        return const Color(0xFF818CF8); // Indigo
      case 'auto':
      case 'coche':
        return const Color(0xFFF87171); // Red
      case 'finanzas':
      case 'savings':
        return const Color(0xFF10B981); // Emerald
      case 'estudio':
      case 'educación':
      case 'estudio / educación':
        return iconYellow;
      case 'urgente':
        return error;
      case 'baño':
      case 'bano':
      case 'bathroom':
        return const Color(0xFF06B6D4); // Cyan
      case 'dormitorio':
      case 'bedroom':
        return accentPurple;
      case 'sala':
      case 'sala / espacios comunes':
      case 'espacios comunes':
        return const Color(0xFFFB923C); // Orange
      case 'mantenimiento':
      case 'mantenimiento del hogar':
      case 'bricolaje':
        return textSecondary;
      case 'niños':
      case 'ninos':
      case 'niños / cuidado':
        return accentOrange;
      case 'administracion':
      case 'administración':
      case 'administración del hogar':
        return const Color(0xFF8B5CF6);
      default:
        return textSecondary;
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
      case 'salud':
        return Icons.favorite_rounded;
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
      return accentBlue;
    }
    if (normalizedType == 'income' ||
        normalizedCategory == 'income' ||
        normalizedCategory == 'ingreso' ||
        normalizedCategory == 'salary' ||
        normalizedCategory == 'sueldo' ||
        normalizedTitle.contains('sueldo') ||
        normalizedTitle.contains('salario')) {
      return success;
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
      return iconBlue;
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
      return accentBlue;
    }
    if (normalizedType == 'income' ||
        normalizedCategory == 'income' ||
        normalizedCategory == 'ingreso' ||
        normalizedCategory == 'salary' ||
        normalizedCategory == 'sueldo' ||
        content.contains('sueldo') ||
        content.contains('salario')) {
      return success;
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
      return iconBlue;
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
    'mercadolibre': 'MercadoLibre',
    'mercado libre': 'MercadoLibre',
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
    'settlement': 'Liquidación de pareja',
    'rent': 'Alquiler',
    'utilities': 'Servicios',
    'restaurants': 'Restaurantes',
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
    'other': 'Otros',
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
      'Dic'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  static String normaliseCategory(String? category) {
    if (category == null || category.trim().isEmpty) return 'general';
    final lower = category.toLowerCase().trim();
    if (lower == 'cleaning') return 'limpieza';
    if (lower == 'kitchen') return 'cocina';
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
}
