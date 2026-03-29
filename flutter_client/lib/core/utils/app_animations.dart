import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
export 'package:homesync_client/shared/widgets/animated_press.dart';
export 'package:homesync_client/shared/widgets/shimmer_loading.dart';
export 'package:homesync_client/shared/widgets/user_avatar.dart';

class AppTransitions {
  static Route<T> slideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.015);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween =
            Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<T> fadeScale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;

        var scaleTween = Tween<double>(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: curve));
        var fadeTween =
            Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }

  static Route<T> slideHorizontal<T>(
      {required Widget page, bool fromRight = true}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;
        final begin =
            fromRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
        const end = Offset.zero;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween =
            Tween<double>(begin: 0.7, end: 1.0).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 280),
    );
  }
}

/// Extension for easy access to premium micro-animations via [flutter_animate].
extension AppAnimationsExtension on Widget {
  Widget animateEntrance({int delay = 0}) {
    return animate()
        .fadeIn(duration: 400.ms, delay: delay.ms, curve: Curves.easeOutCubic)
        .slideY(
            begin: 0.1,
            end: 0,
            duration: 400.ms,
            delay: delay.ms,
            curve: Curves.easeOutCubic);
  }

  Widget animateStaggered(int index) {
    return animateEntrance(delay: index * 40);
  }

  Widget animateScaleIn({int delay = 0}) {
    return animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 500.ms,
          delay: delay.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 300.ms, delay: delay.ms);
  }

  Widget animatePulse({bool active = true}) {
    if (!active) return this;
    return animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.02, 1.02),
            duration: 1000.ms);
  }
}

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final safeIndex = widget.index.clamp(0, widget.children.length - 1);

    return AnimatedSwitcher(
      duration: widget.duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0.0, 0.035),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(safeIndex),
        child: widget.children[safeIndex],
      ),
    );
  }
}

class CelebrationOverlay extends StatelessWidget {
  final Widget child;
  final ConfettiController controller;

  const CelebrationOverlay({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.05,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }
}

class SuccessCelebration {
  static void show(BuildContext context,
      {required String title, required String message, String? icon}) {
    final confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CelebrationDialog(
        title: title,
        message: message,
        icon: icon,
        confettiController: confettiController,
      ),
    );
  }
}

class _CelebrationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? icon;
  final ConfettiController confettiController;

  const _CelebrationDialog({
    required this.title,
    required this.message,
    this.icon,
    required this.confettiController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],
        ),
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0FDF4),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    icon ?? '🎉',
                    style: const TextStyle(fontSize: 48),
                  ),
                ).animate().shake(delay: 400.ms),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF166534)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey[600], height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      confettiController.stop();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text('¡GENIAL!',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        ),
      ],
    );
  }
}

// Removed duplicate AppAnimationsExtension and legacy animation classes.
