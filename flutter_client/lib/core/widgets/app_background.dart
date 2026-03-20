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
    final background = isDarkMode
        ? const [Color(0xFF1B1716), Color(0xFF221D1A), Color(0xFF171312)]
        : const [Color(0xFFFFFCF9), Color(0xFFFFF6EE), Color(0xFFFFFBF8)];

    final orbPrimary = isDarkMode
        ? AppColors.primary.withValues(alpha: 0.12)
        : AppColors.primary.withValues(alpha: 0.14);
    final orbSecondary = isDarkMode
        ? AppColors.sage.withValues(alpha: 0.10)
        : AppColors.sage.withValues(alpha: 0.16);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: background,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -40,
          child: _GlowOrb(
            size: 240,
            color: orbPrimary,
          ),
        ),
        Positioned(
          top: 180,
          left: -70,
          child: _GlowOrb(
            size: 180,
            color: orbSecondary,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _DotTexturePainter(isDarkMode: isDarkMode),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: color.a * 0.45),
              Colors.transparent,
            ],
          ),
        ),
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
          .withValues(alpha: isDarkMode ? 0.035 : 0.025)
      ..style = PaintingStyle.fill;

    const spacing = 52.0;
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
