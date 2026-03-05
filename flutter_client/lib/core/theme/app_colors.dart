import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Stitch Design - Warm Scandi Theme)
  static const Color primary = Color(0xFFEE652B);
  static const Color primaryLight = Color(0xFFFFF1EE);
  static const Color primaryDark = Color(0xFFD85A23);

  // Backgrounds
  static const Color background = Color(0xFFFFFCF9);
  static const Color backgroundDark = Color(0xFF221510);
  static const Color surface = Color(0xFFFFF8F2);
  static const Color surfaceDark = Color(0xFF2D2727);
  static const Color cardDark = Color(0xFF302B2A);
  static const Color cardLight = Color(0xFFFFFFFF);

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
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
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

  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFE2E8F0);
  static const Color cardBorder = border;
  static const Color inputBorder = border;
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color shadow = Color(0x0A4A4443);

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
    Color(0xFFFFFFFF),
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
      case 'supermarket':
        return accentGold;
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
      case 'income':
      case 'ingreso':
      case 'salary':
      case 'transfer':
      case 'sales':
      case 'gift_income':
      case 'other_income':
        return success;
      case 'baño':
      case 'bano':
      case 'bathroom':
        return const Color(0xFF06B6D4); // Cyan
      case 'dormitorio':
      case 'bedroom':
        return accentPurple;
      case 'sala':
      case 'sala / espacios comunes':
        return const Color(0xFFFB923C); // Orange
      case 'mantenimiento':
      case 'bricolaje':
        return textSecondary;
      case 'niños':
      case 'ninos':
        return accentOrange;
      case 'utilities':
        return accentTeal;
      case 'rent':
        return primary;
      case 'restaurants':
        return const Color(0xFFF06292);
      case 'transport':
        return const Color(0xFF4DB6AC);
      case 'entertainment':
        return const Color(0xFF9575CD);
      case 'health':
        return accentRed;
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
      case 'ropa':
        return Icons.checkroom_rounded;
      case 'auto':
      case 'coche':
        return Icons.directions_car_rounded;
      case 'finanzas':
      case 'savings':
        return Icons.savings_rounded;
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
      case 'income':
      case 'ingreso':
      case 'salary':
      case 'transfer':
      case 'sales':
      case 'gift_income':
      case 'other_income':
        return Icons.payments_rounded;
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
        return Icons.build_rounded;
      case 'niños':
      case 'ninos':
        return Icons.child_care_rounded;
      case 'utilities':
        return Icons.lightbulb_outline_rounded;
      case 'rent':
        return Icons.home_work_rounded;
      case 'restaurants':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'entertainment':
        return Icons.movie_creation_outlined;
      case 'health':
        return Icons.medical_services_outlined;
      default:
        return Icons.home_work_rounded;
    }
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
    'outdoor': '🌱',
    'exterior': '🌱',
    'garden': '🌱',
    'jardin': '🌱',
    'jardín': '🌱',
    'supermarket': '🛒',
    'compras': '🛒',
    'ropa': '👕',
    'residuos': '🗑️',
    'sala': '🧹',
    'estudio': '📚',
    'mantenimiento': '🔧',
    'niños': '👶',
    'urgente': '🚨',
    'income': '💰',
    'salary': '💵',
    'transfer': '💱',
    'sales': '📈',
    'gift_income': '🎁',
    'other_income': '💰',
    'other': '📦',
    'utilities': '💡',
    'rent': '🏠',
    'restaurants': '🍽️',
    'transport': '🚗',
    'entertainment': '🎬',
    'health': '💊',
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
    'compras': 'Compras',
    'ropa': 'Ropa',
    'residuos': 'Residuos',
    'sala': 'Sala / Espacios comunes',
    'estudio': 'Estudio / Educación',
    'mantenimiento': 'Mantenimiento',
    'niños': 'Niños',
    'urgente': 'Urgente',
    'income': 'Ingreso General',
    'salary': 'Salario',
    'transfer': 'Transferencia recibida',
    'sales': 'Ventas / Negocio',
    'gift_income': 'Regalo',
    'other_income': 'Otros Ingresos',
    'other': 'Otros',
    'utilities': 'Servicios',
    'rent': 'Alquiler',
    'restaurants': 'Restaurantes',
    'transport': 'Transporte',
    'entertainment': 'Entretenimiento',
    'health': 'Salud',
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
        lower == 'jardin') return 'jardin';
    if (lower == 'supermarket') return 'compras';
    if (lower == 'savings') return 'finanzas';
    if (lower == 'niños' ||
        lower == 'niño' ||
        lower == 'ninos' ||
        lower == 'niña') return 'ninos';
    return lower;
  }
}
