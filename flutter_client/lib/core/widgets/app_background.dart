import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final bool isDarkMode;

  const AppBackground({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isDarkMode
        ? const [
            Color(0xFF0F0E1A),
            Color(0xFF151325),
          ]
        : const [
            AppColors.background,
            AppColors.surface,
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomPaint(
        painter: _DotTexturePainter(isDarkMode: isDarkMode),
      ),
    );
  }
}

class _DotTexturePainter extends CustomPainter {
  final bool isDarkMode;

  _DotTexturePainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? Colors.white : AppColors.shadowBase)
          .withValues(alpha: isDarkMode ? 0.04 : 0.03)
      ..style = PaintingStyle.fill;

    const spacing = 48.0;
    const radius = 1.0;

    for (double y = 0; y <= size.height; y += spacing) {
      for (double x = 0; x <= size.width; x += spacing) {
        canvas.drawCircle(Offset(x + 12, y + 12), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotTexturePainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode;
  }
}

