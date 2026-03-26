import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HomeSyncLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool isDark;

  const HomeSyncLogo({
    super.key,
    this.size = 100,
    this.showShadow = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [AppColors.primaryDark, AppColors.primary]
            : [AppColors.primary, const Color(0xFFFF9866)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: showShadow ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.15),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: size * 0.08,
            offset: Offset(0, size * 0.04),
          ),
        ] : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle inner highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(size * 0.3)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // House icon + Sync icon
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.home_rounded,
                size: size * 0.55,
                color: Colors.white,
              ),
              Positioned(
                bottom: size * 0.22,
                child: Container(
                  padding: EdgeInsets.all(size * 0.02),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sync_rounded,
                    size: size * 0.15,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
