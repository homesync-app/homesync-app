import 'package:flutter/material.dart';

class ThemePalette {
  final String name;
  final Color primary;
  final Color secondary;
  final List<Color> gradient;

  const ThemePalette({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.gradient,
  });

  static const List<ThemePalette> all = [
    ThemePalette(
      name: 'Naranja (Original)',
      primary: Color(0xFFEE652B),
      secondary: Color(0xFFFF8A65),
      gradient: [Color(0xFFEE652B), Color(0xFFFF8A65)],
    ),
    ThemePalette(
      name: 'Oscuro',
      primary: Color(0xFF111827),
      secondary: Color(0xFF1F2937),
      gradient: [Color(0xFF111827), Color(0xFF1F2937)],
    ),
    ThemePalette(
      name: 'Índigo',
      primary: Color(0xFF6366F1),
      secondary: Color(0xFF818CF8),
      gradient: [Color(0xFF6366F1), Color(0xFF818CF8)],
    ),
    ThemePalette(
      name: 'Rosa',
      primary: Color(0xFFF43F5E),
      secondary: Color(0xFFFB7185),
      gradient: [Color(0xFFF43F5E), Color(0xFFFB7185)],
    ),
    ThemePalette(
      name: 'Esmeralda',
      primary: Color(0xFF10B981),
      secondary: Color(0xFF34D399),
      gradient: [Color(0xFF10B981), Color(0xFF34D399)],
    ),
    ThemePalette(
      name: 'Violeta',
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFFA78BFA),
      gradient: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    ),
    ThemePalette(
      name: 'Ámbar',
      primary: Color(0xFFF59E0B),
      secondary: Color(0xFFFBBF24),
      gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    ),
    ThemePalette(
      name: 'Cian',
      primary: Color(0xFF06B6D4),
      secondary: Color(0xFF22D3EE),
      gradient: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
    ),
  ];
}
