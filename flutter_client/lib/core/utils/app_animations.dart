import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static Route<T> slideHorizontal<T>({
    required Widget page,
    bool fromRight = true,
  }) {
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
          curve: Curves.easeOutCubic,
        );
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
      duration: 1000.ms,
    );
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
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _controller.forward(from: 0.0);
      setState(() {
        _currentIndex = widget.index;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    return IndexedStack(
      index: _currentIndex,
      children: List.generate(widget.children.length, (i) {
        // Only animate the currently active child; the rest stay alive but hidden.
        if (i == _currentIndex) {
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.018),
                end: Offset.zero,
              ).animate(curve),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.992, end: 1).animate(curve),
                child: widget.children[i],
              ),
            ),
          );
        }
        return widget.children[i];
      }),
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
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? icon,
  }) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _CelebrationDialog(
        title: title,
        message: message,
        icon: icon,
      ),
    );
  }
}

class _CelebrationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? icon;

  const _CelebrationDialog({
    required this.title,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final successColor = colorScheme.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: successColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon == null ? Icons.check_rounded : Icons.emoji_events_rounded,
                color: successColor,
                size: 32,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.86, 0.86),
                  end: const Offset(1, 1),
                  duration: 260.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 180.ms),
            const SizedBox(height: 20),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: successColor.withValues(alpha: 0.14),
                  foregroundColor: successColor,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Listo',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 160.ms, curve: Curves.easeOutCubic).scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1, 1),
            duration: 220.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

// Removed duplicate AppAnimationsExtension and legacy animation classes.
