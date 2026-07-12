import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';

export 'package:homesync_client/shared/widgets/animated_amount.dart';
export 'package:homesync_client/shared/widgets/animated_press.dart';
export 'package:homesync_client/shared/widgets/shimmer_loading.dart';
export 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Extension for easy access to premium micro-animations via [flutter_animate].
extension AppAnimationsExtension on Widget {
  Widget animateEntrance({int delay = 0}) {
    return animate()
        .fadeIn(
          duration: AppMotion.slow,
          delay: delay.ms,
          curve: AppMotion.standard,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: AppMotion.slow,
          delay: delay.ms,
          curve: AppMotion.standard,
        );
  }

  Widget animateStaggered(int index) {
    return animateEntrance(delay: (index % 8) * 40);
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

  /// Entrada crisp para contenido de sheets/cards frecuentes: scale sutil sin
  /// rebote. Para celebraciones raras usar [animateScaleIn] (elastic).
  Widget animatePopIn({int delay = 0}) {
    return animate()
        .fadeIn(
          duration: AppMotion.fast,
          delay: delay.ms,
          curve: AppMotion.standard,
        )
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: AppMotion.normal,
          delay: delay.ms,
          curve: AppMotion.standard,
        );
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
    this.duration = AppMotion.normal,
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentIndex;

  /// Montaje perezoso: cada tab se construye recién la primera vez que se
  /// visita y después queda vivo (conserva scroll y estado). Evita pagar el
  /// build de todos los tabs en el primer frame del MainScreen.
  late Set<int> _visitedIndices;
  late int _childCount;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _visitedIndices = {widget.index};
    _childCount = widget.children.length;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia la cantidad de tabs (cambio de modo/rol del hogar) los
    // índices dejan de significar lo mismo: resetear lo visitado.
    if (widget.children.length != _childCount) {
      _childCount = widget.children.length;
      _visitedIndices = {widget.index};
    }
    _visitedIndices.add(widget.index);
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
        if (!_visitedIndices.contains(i)) {
          return const SizedBox.shrink();
        }
        // Todos los hijos visitados comparten la MISMA estructura de
        // wrappers: si el árbol cambiara de forma al activarse/ocultarse
        // (p.ej. sacar el FadeTransition), el Element se remontaría y el
        // tab perdería scroll y estado en cada cambio. Solo se conmuta la
        // animación (los ocultos quedan clavados en el frame final) y
        // TickerMode, para que un tab oculto no siga consumiendo frames.
        final bool isActive = i == _currentIndex;
        final Animation<double> drive =
            isActive ? curve : const AlwaysStoppedAnimation(1.0);
        return FadeTransition(
          opacity: drive,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1).animate(drive),
            child: TickerMode(
              enabled: isActive,
              child: widget.children[i],
            ),
          ),
        );
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
    AppHaptics.celebrate();

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
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
