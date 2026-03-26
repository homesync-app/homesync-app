import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/widgets/homesync_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _logoController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _progress;
  late Animation<double> _particleAnim;

  @override
  void initState() {
    super.initState();

    // Logo: scale + fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    // Progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _progress = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    // Floating particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _particleAnim = CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    );

    // Sequence: logo first, then progress bar
    _logoController.forward().then((_) {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF8F2), // warm cream
                  Color(0xFFFFF1E8), // soft peach
                  Color(0xFFFFE0CC), // warm orange tint
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── Floating decorative circles ──────────────────────────────────
          AnimatedBuilder(
            animation: _particleAnim,
            builder: (context, _) {
              return CustomPaint(
                painter: _SplashParticlePainter(_particleAnim.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo icon
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: HomeSyncLogo(size: 110),
                  ),
                ),

                const SizedBox(height: 32),

                // App name
                FadeTransition(
                  opacity: _logoOpacity,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _logoController,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                    )),
                    child: const Text(
                      'HomeSync',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _logoController,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                  ),
                  child: const Text(
                    'Tu hogar, en sincronía',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF84A59D),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) {
                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: _progress.value,
                              minHeight: 3,
                              backgroundColor: const Color(0xFFE2D9D0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Floating particle painter ──────────────────────────────────────────────────
class _SplashParticlePainter extends CustomPainter {
  final double progress;

  _SplashParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final particles = [
      const _Particle(x: 0.12, y: 0.15, radius: 60, alpha: 0.07, speed: 0.3),
      const _Particle(x: 0.85, y: 0.08, radius: 90, alpha: 0.05, speed: 0.2),
      const _Particle(x: 0.72, y: 0.78, radius: 70, alpha: 0.06, speed: 0.25),
      const _Particle(x: 0.05, y: 0.65, radius: 50, alpha: 0.08, speed: 0.35),
      const _Particle(x: 0.92, y: 0.50, radius: 40, alpha: 0.05, speed: 0.4),
    ];

    for (final p in particles) {
      final dy = size.height * 0.04 * (0.5 - (progress * p.speed % 1.0)).abs();
      paint.color = const Color(0xFFEE652B).withValues(alpha: p.alpha);
      canvas.drawCircle(
        Offset(size.width * p.x, size.height * p.y + dy),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SplashParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  final double x, y, radius, alpha, speed;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
    required this.speed,
  });
}
