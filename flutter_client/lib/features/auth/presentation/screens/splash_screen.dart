import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _videoAsset = 'assets/images/splash_cat_lights.mp4';

  late final AnimationController _loadingController;
  VideoPlayerController? _videoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    try {
      var assetPath = _videoAsset;
      if (kIsWeb && assetPath.startsWith('assets/')) {
        assetPath = assetPath.replaceFirst('assets/', '');
      }

      final controller = VideoPlayerController.asset(assetPath);
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _videoReady = true;
      });
    } catch (error, stackTrace) {
      log.e(
        'Error initializing splash video',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _loadingController,
        builder: (context, _) {
          final progress = _loadingController.value;
          return Stack(
            children: [
              Positioned.fill(
                child: _videoReady
                    ? _SplashVideoBackdrop(controller: _videoController!)
                    : const _FallbackBackdrop(),
              ),
              const Positioned.fill(child: _SplashAtmosphere()),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: _BrandPanel(progress: progress),
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

class _SplashVideoBackdrop extends StatelessWidget {
  final VideoPlayerController controller;

  const _SplashVideoBackdrop({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

class _FallbackBackdrop extends StatelessWidget {
  const _FallbackBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFFF8F0),
            Color(0xFFFFE8D8),
            AppColors.primaryLight,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -40,
            child: _GlowOrb(
              size: 220,
              color: Color(0x3DE88D67),
            ),
          ),
          Positioned(
            right: -70,
            bottom: 120,
            child: _GlowOrb(
              size: 260,
              color: Color(0x2E84A59D),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashAtmosphere extends StatelessWidget {
  const _SplashAtmosphere();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x10000000),
            Colors.transparent,
            Color(0x40F6E8D8),
            Color(0xCCEFE0D0),
          ],
          stops: [0.0, 0.4, 0.74, 1.0],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  final double progress;

  const _BrandPanel({required this.progress});

  @override
  Widget build(BuildContext context) {
    final wave = 0.5 + 0.5 * math.sin(progress * math.pi * 2);
    final fill = 0.24 + (wave * 0.62);
    final breathing = 0.92 + (wave * 0.08);

    return Transform.scale(
      scale: breathing,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xEAFBF5EE),
                  Color(0xDDF6E8D8),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0x8CFFFFFF),
                width: 1.1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x167D5A3C),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HomeSync',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.1,
                            color: const Color(0xFF4B352A),
                          ) ??
                      const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 33,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.1,
                        color: Color(0xFF4B352A),
                      ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Preparando tu hogar compartido.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7B675C),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                _ElegantProgressBar(progress: fill),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ElegantProgressBar extends StatelessWidget {
  final double progress;

  const _ElegantProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 7,
        decoration: BoxDecoration(
          color: const Color(0x1A8E6F5A),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      AppColors.sage,
                      AppColors.accentPeach,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPeach.withValues(alpha: 0.16),
                      blurRadius: 10,
                      spreadRadius: 0.1,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment((progress.clamp(0.0, 1.0) * 2) - 1, 0),
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFBF7),
                  border: Border.all(
                    color: AppColors.accentPeach.withValues(alpha: 0.5),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sage.withValues(alpha: 0.1),
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
