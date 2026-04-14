import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';

List<Map<String, dynamic>> buildExpenseCategories() {
  return [
    {
      'id': 'supermarket',
      'name': 'Supermercado',
      'icon': '🛒',
      'color': CategoryMapping.getCategoryColor('supermarket'),
    },
    {
      'id': 'utilities',
      'name': 'Servicios',
      'icon': '💡',
      'color': CategoryMapping.getCategoryColor('utilities'),
    },
    {
      'id': 'rent',
      'name': 'Alquiler y hogar',
      'icon': '🏠',
      'color': CategoryMapping.getCategoryColor('rent'),
    },
    {
      'id': 'restaurants',
      'name': 'Salidas y comidas',
      'icon': '🍽️',
      'color': CategoryMapping.getCategoryColor('restaurants'),
    },
    {
      'id': 'transport',
      'name': 'Transporte',
      'icon': '🚙',
      'color': CategoryMapping.getCategoryColor('transport'),
    },
    {
      'id': 'entertainment',
      'name': 'Ocio y planes',
      'icon': '🎬',
      'color': CategoryMapping.getCategoryColor('entertainment'),
    },
    {
      'id': 'health',
      'name': 'Salud',
      'icon': '💊',
      'color': CategoryMapping.getCategoryColor('health'),
    },
    {
      'id': 'finanzas',
      'name': 'Ahorro e inversión',
      'icon': '🏦',
      'color': CategoryMapping.getCategoryColor('finanzas'),
    },
    {
      'id': 'settlement',
      'name': 'Liquidación',
      'icon': '🤝',
      'color': CategoryMapping.getCategoryColor('settlement'),
    },
    {
      'id': 'mercadolibre',
      'name': 'Compras online',
      'icon': '🛍️',
      'color': CategoryMapping.getCategoryColor('mercadolibre'),
    },
    {
      'id': 'pets',
      'name': 'Mascotas',
      'icon': '🐾',
      'color': CategoryMapping.getCategoryColor('pets'),
    },
    {
      'id': 'clothing',
      'name': 'Ropa y calzado',
      'icon': '👗',
      'color': CategoryMapping.getCategoryColor('clothing'),
    },
    {
      'id': 'electronics',
      'name': 'Tecnología',
      'icon': '📱',
      'color': CategoryMapping.getCategoryColor('electronics'),
    },
    {
      'id': 'education',
      'name': 'Educación',
      'icon': '📚',
      'color': CategoryMapping.getCategoryColor('education'),
    },
    {
      'id': 'other',
      'name': 'Otros gastos',
      'icon': '📦',
      'color': CategoryMapping.getCategoryColor('other'),
    },
  ];
}

List<Map<String, dynamic>> buildIncomeCategories() {
  return [
    {
      'id': 'salary',
      'name': 'Sueldo',
      'icon': '💰',
      'color': AppColors.success,
    },
    {
      'id': 'freelance',
      'name': 'Freelance',
      'icon': '💻',
      'color': AppColors.accentBlue,
    },
    {
      'id': 'ventas',
      'name': 'Ventas',
      'icon': '📊',
      'color': AppColors.accentTeal,
    },
    {
      'id': 'bonus',
      'name': 'Bono o premio',
      'icon': '🎊',
      'color': AppColors.accentPurple,
    },
    {
      'id': 'reembolso',
      'name': 'Reembolso',
      'icon': '🔙',
      'color': AppColors.sage,
    },
    {
      'id': 'gift',
      'name': 'Regalo',
      'icon': '🎁',
      'color': const Color(0xFFFF8A65),
    },
    {
      'id': 'investment',
      'name': 'Rendimiento',
      'icon': '📈',
      'color': const Color(0xFF4CAF50),
    },
    {
      'id': 'other',
      'name': 'Otros ingresos',
      'icon': '💵',
      'color': AppColors.success,
    },
  ];
}
