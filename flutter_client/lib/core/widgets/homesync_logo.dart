import 'package:flutter/material.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.1),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: size * 0.08,
                  offset: Offset(0, size * 0.04),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          'assets/images/homesync_logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
