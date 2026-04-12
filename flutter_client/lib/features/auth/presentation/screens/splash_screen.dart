import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _sceneController;
  late final AnimationController _loadingController;

  late final Animation<double> _sceneReveal;
  late final Animation<double> _roomGlow;
  late final Animation<double> _catSettle;
  late final Animation<double> _windowZoom;
  late final Animation<double> _copyOpacity;

  @override
  void initState() {
    super.initState();
    _sceneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _sceneReveal = CurvedAnimation(
      parent: _sceneController,
      curve: const Interval(0.0, 0.58, curve: Curves.easeOutCubic),
    );
    _roomGlow = CurvedAnimation(
      parent: _sceneController,
      curve: const Interval(0.18, 0.9, curve: Curves.easeInOutCubic),
    );
    _catSettle = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(
        parent: _sceneController,
        curve: const Interval(0.12, 0.62, curve: Curves.easeOutBack),
      ),
    );
    _windowZoom = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _sceneController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _copyOpacity = CurvedAnimation(
      parent: _sceneController,
      curve: const Interval(0.42, 1.0, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _sceneController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_sceneController, _loadingController]),
        builder: (context, _) {
          final screenSize = MediaQuery.of(context).size;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFFFEFC),
                        const Color(0xFFFFF7F0),
                        AppColors.primaryLight.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -screenSize.height * 0.08,
                left: -screenSize.width * 0.12,
                child: _SoftOrb(
                  size: screenSize.width * 0.52,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                right: -screenSize.width * 0.2,
                bottom: screenSize.height * 0.14,
                child: _SoftOrb(
                  size: screenSize.width * 0.72,
                  color: AppColors.sage.withValues(alpha: 0.08),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Transform.scale(
                        scale: _windowZoom.value,
                        child: Opacity(
                          opacity: _sceneReveal.value.clamp(0, 1),
                          child: _WindowSplashArtwork(
                            reveal: _sceneReveal.value,
                            glow: _roomGlow.value,
                            catOffset: _catSettle.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      FadeTransition(
                        opacity: _copyOpacity,
                        child: const Column(
                          children: [
                            Text(
                              'Entrando al hogar',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Todo se está acomodando para recibirte.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeTransition(
                        opacity: _copyOpacity,
                        child: const Column(
                          children: [
                            _LoadingPulse(progress: 0),
                            SizedBox(height: 14),
                            Text(
                              'Sincronizando hogar, tareas y finanzas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WindowSplashArtwork extends StatelessWidget {
  final double reveal;
  final double glow;
  final double catOffset;

  const _WindowSplashArtwork({
    required this.reveal,
    required this.glow,
    required this.catOffset,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.78,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(46),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 42,
                        offset: const Offset(0, 24),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: width * 0.05,
                right: width * 0.05,
                top: height * 0.05,
                bottom: height * 0.06,
                child: CustomPaint(
                  painter: _WindowFramePainter(
                    glow: glow,
                    reveal: reveal,
                  ),
                ),
              ),
              Positioned(
                left: width * 0.14,
                right: width * 0.14,
                top: height * 0.14,
                bottom: height * 0.18,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.lerp(
                            const Color(0xFFF7FBFD),
                            const Color(0xFFFFF2E4),
                            glow,
                          )!,
                          Color.lerp(
                            const Color(0xFFFFFCF7),
                            const Color(0xFFFFEEDB),
                            glow * 0.9,
                          )!,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: height * 0.42,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.88),
                                  const Color(0xFFFFF4E7).withValues(
                                    alpha: 0.78 + glow * 0.18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: width * 0.04,
                          top: height * 0.08,
                          child: Container(
                            width: width * 0.16,
                            height: height * 0.34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F8F4),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        Positioned(
                          right: width * 0.08,
                          top: height * 0.1,
                          child: Container(
                            width: width * 0.08,
                            height: height * 0.28,
                            color: Colors.white.withValues(alpha: 0.94),
                          ),
                        ),
                        Positioned(
                          top: height * 0.12,
                          left: width * 0.13,
                          child: Container(
                            width: width * 0.28,
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6B286),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        Positioned(
                          top: height * 0.135,
                          left: width * 0.16,
                          child: Row(
                            children: [
                              const _BookAccent(height: 42, color: Color(0xFFC59C6A)),
                              const SizedBox(width: 8),
                              const _BookAccent(height: 36, color: Color(0xFFDBC8B0)),
                              const SizedBox(width: 8),
                              Container(
                                width: 28,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECE6DD),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: height * 0.16,
                          left: width * 0.45,
                          child: _PlantBlob(
                            size: width * 0.18,
                            color: const Color(0xFF7EA07D),
                          ),
                        ),
                        Positioned(
                          top: height * 0.16,
                          right: width * 0.11,
                          child: _PendantLamp(glow: glow, size: width * 0.12),
                        ),
                        Positioned(
                          top: height * 0.21,
                          left: width * 0.08,
                          child: _PlantBlob(
                            size: width * 0.15,
                            color: const Color(0xFF8EA98C),
                          ),
                        ),
                        Positioned(
                          left: width * 0.11,
                          bottom: height * 0.26,
                          child: Container(
                            width: width * 0.28,
                            height: height * 0.14,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCFA77A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        Positioned(
                          left: width * 0.14,
                          bottom: height * 0.28,
                          child: _MiniLamp(glow: glow),
                        ),
                        Positioned(
                          right: width * 0.16,
                          bottom: height * 0.22,
                          child: Container(
                            width: width * 0.28,
                            height: height * 0.18,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2E6D8),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        Positioned(
                          right: width * 0.18,
                          bottom: height * 0.28,
                          child: Container(
                            width: width * 0.11,
                            height: height * 0.055,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9E73),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        Positioned(
                          left: width * 0.22,
                          bottom: height * 0.17,
                          child: Container(
                            width: width * 0.25,
                            height: height * 0.075,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDAB284),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        Positioned(
                          left: width * 0.19,
                          bottom: height * 0.13,
                          child: _PlantBlob(
                            size: width * 0.13,
                            color: const Color(0xFF6E9872),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(0.1, 0.12),
                                radius: 0.95,
                                colors: [
                                  const Color(0xFFFFF3DF).withValues(
                                    alpha: 0.22 + glow * 0.18,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: width * 0.13,
                right: width * 0.11,
                bottom: height * 0.11,
                child: Container(
                  height: height * 0.06,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7B083),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA26D3B).withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: width * 0.16,
                bottom: height * 0.095 + catOffset,
                child: Transform.rotate(
                  angle: -0.06,
                  child: _CatSilhouette(glow: glow),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingPulse extends StatelessWidget {
  final double progress;

  const _LoadingPulse({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          final phase = ((progress + index * 0.2) % 1.0);
          final opacity = 0.25 + (1 - (phase - 0.5).abs() * 2) * 0.55;
          final scale = 0.72 + (1 - (phase - 0.5).abs() * 2) * 0.28;

          return Transform.scale(
            scale: scale.clamp(0.72, 1.0),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: opacity.clamp(0.2, 0.8)),
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftOrb({required this.size, required this.color});

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
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowFramePainter extends CustomPainter {
  final double glow;
  final double reveal;

  const _WindowFramePainter({
    required this.glow,
    required this.reveal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(34),
    );
    final mid = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.035, size.height * 0.03,
          size.width * 0.93, size.height * 0.93),
      const Radius.circular(30),
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.075,
          size.width * 0.84, size.height * 0.84),
      const Radius.circular(26),
    );

    final woodShadow = Paint()
      ..color = const Color(0xFF9E6E45).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawRRect(outer.shift(const Offset(0, 10)), woodShadow);

    final outerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFDDB98A),
          Color(0xFFB37A48),
          Color(0xFFF2D6A5),
        ],
      ).createShader(outer.outerRect);
    canvas.drawRRect(outer, outerPaint);

    final midPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE6C18F),
          Color(0xFFA06B3F),
        ],
      ).createShader(mid.outerRect);
    canvas.drawRRect(mid, midPaint);

    final innerPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFFF7E5CC),
        const Color(0xFFFFF4E6),
        reveal,
      )!;
    canvas.drawRRect(inner, innerPaint);

    final sillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.14,
        size.height * 0.92,
        size.width * 0.72,
        size.height * 0.07,
      ),
      const Radius.circular(18),
    );
    final sillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE9CA9F),
          Color(0xFFC58D56),
        ],
      ).createShader(sillRect.outerRect);
    canvas.drawRRect(sillRect, sillPaint);

    final warmGlow = Paint()
      ..color = const Color(0xFFFFD9A8).withValues(alpha: 0.12 + glow * 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      size.width * 0.18,
      warmGlow,
    );
  }

  @override
  bool shouldRepaint(covariant _WindowFramePainter oldDelegate) {
    return oldDelegate.glow != glow || oldDelegate.reveal != reveal;
  }
}

class _CatSilhouette extends StatelessWidget {
  final double glow;

  const _CatSilhouette({required this.glow});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 126,
      child: CustomPaint(
        painter: _CatPainter(glow: glow),
      ),
    );
  }
}

class _CatPainter extends CustomPainter {
  final double glow;

  const _CatPainter({required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final fur = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFC99362),
          Color(0xFF9D6036),
        ],
      ).createShader(Offset.zero & size);
    final stripe = Paint()
      ..color = const Color(0xFF8B552E).withValues(alpha: 0.32)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final collar = Paint()
      ..color = Color.lerp(
        const Color(0xFF7BB7A2),
        const Color(0xFF9CCBB9),
        glow,
      )!;

    final body = Path()
      ..moveTo(size.width * 0.28, size.height * 0.42)
      ..quadraticBezierTo(
          size.width * 0.12, size.height * 0.7, size.width * 0.34, size.height * 0.94)
      ..quadraticBezierTo(
          size.width * 0.72, size.height * 1.0, size.width * 0.82, size.height * 0.76)
      ..quadraticBezierTo(
          size.width * 0.9, size.height * 0.5, size.width * 0.62, size.height * 0.34)
      ..close();
    canvas.drawPath(body, fur);

    final head = Path()
      ..moveTo(size.width * 0.36, size.height * 0.1)
      ..lineTo(size.width * 0.3, size.height * 0.28)
      ..quadraticBezierTo(
          size.width * 0.48, size.height * 0.4, size.width * 0.62, size.height * 0.28)
      ..lineTo(size.width * 0.57, size.height * 0.06)
      ..quadraticBezierTo(
          size.width * 0.48, size.height * 0.14, size.width * 0.36, size.height * 0.1)
      ..close();
    canvas.drawPath(head, fur);

    final chest = Paint()..color = const Color(0xFFE9C59A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.56, size.height * 0.58),
        width: size.width * 0.22,
        height: size.height * 0.26,
      ),
      chest,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.36,
          size.height * 0.28,
          size.width * 0.24,
          8,
        ),
        const Radius.circular(999),
      ),
      collar,
    );

    for (final offset in [0.34, 0.43, 0.52, 0.63]) {
      canvas.drawArc(
        Rect.fromLTWH(size.width * offset, size.height * 0.42, 12, 40),
        math.pi * 1.1,
        math.pi * 0.9,
        false,
        stripe,
      );
    }
    for (final offset in [0.3, 0.42, 0.54]) {
      canvas.drawArc(
        Rect.fromLTWH(size.width * offset, size.height * 0.62, 16, 44),
        math.pi * 1.05,
        math.pi * 0.8,
        false,
        stripe,
      );
    }

    final tail = Path()
      ..moveTo(size.width * 0.7, size.height * 0.84)
      ..quadraticBezierTo(
          size.width * 0.96, size.height * 0.92, size.width * 0.82, size.height * 0.58);
    canvas.drawPath(
      tail,
      Paint()
        ..color = const Color(0xFFAA6E40)
        ..strokeWidth = 9
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(tail, stripe);
  }

  @override
  bool shouldRepaint(covariant _CatPainter oldDelegate) {
    return oldDelegate.glow != glow;
  }
}

class _PendantLamp extends StatelessWidget {
  final double glow;
  final double size;

  const _PendantLamp({required this.glow, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 2,
          height: size * 1.2,
          color: const Color(0xFFB99D7A),
        ),
        Container(
          width: size,
          height: size * 0.72,
          decoration: BoxDecoration(
            color: const Color(0xFFD8A367),
            borderRadius: BorderRadius.circular(size),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD39B).withValues(alpha: 0.18 + glow * 0.22),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniLamp extends StatelessWidget {
  final double glow;

  const _MiniLamp({required this.glow});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF5D7AA),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD9A5).withValues(alpha: 0.12 + glow * 0.18),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
          Container(
            width: 6,
            height: 22,
            color: const Color(0xFFC69A65),
          ),
          Container(
            width: 20,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFC69A65),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _PlantBlob({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final angle in [-0.9, -0.35, 0.25, 0.75])
            Transform.rotate(
              angle: angle,
              child: Container(
                width: size * 0.24,
                height: size * 0.78,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookAccent extends StatelessWidget {
  final double height;
  final Color color;

  const _BookAccent({
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
