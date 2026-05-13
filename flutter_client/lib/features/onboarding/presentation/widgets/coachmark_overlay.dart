import 'dart:math' as math;
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/onboarding/domain/coachmark_step.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/couple_home_tour_controller.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/tour_target_keys.dart';
import 'package:homesync_client/features/onboarding/presentation/widgets/spotlight_painter.dart';

/// Padding around the target rect when carving the spotlight hole.
const _kSpotlightPadding = 12.0;
const _kSpotlightRadius = 22.0;
const _kTooltipMaxWidth = 360.0;
const _kTooltipMargin = 20.0;
const _kTooltipGap = 18.0;

/// Mounted at the root of MainScreen so it sits above the entire couple home
/// (including bottom nav) when the tour is active.
class CoachmarkOverlay extends ConsumerStatefulWidget {
  const CoachmarkOverlay({super.key});

  @override
  ConsumerState<CoachmarkOverlay> createState() => _CoachmarkOverlayState();
}

class _CoachmarkOverlayState extends ConsumerState<CoachmarkOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final AnimationController _stepCtrl;
  late final ConfettiController _confettiCtrl;

  Rect? _currentRect;
  Rect? _previousRect;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _confettiCtrl =
        ConfettiController(duration: const Duration(milliseconds: 1400));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _stepCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(coupleHomeTourControllerProvider);
    if (!tourState.isActive) return const SizedBox.shrink();

    final steps = ref
        .read(coupleHomeTourControllerProvider.notifier)
        .stepsFor(hasTasks: tourState.hasTasks);

    if (tourState.currentStep >= steps.length) {
      return const SizedBox.shrink();
    }

    final step = steps[tourState.currentStep];
    final keys = ref.watch(tourTargetKeysProvider);

    // Resolve target rect (only relevant for spotlight steps).
    Rect? targetRect;
    if (step.kind == CoachmarkStepKind.spotlight && step.target != null) {
      targetRect = _findTargetRect(keys[step.target!]);
    }

    // Detect rect transition to animate movement of the spotlight.
    if (targetRect != _currentRect) {
      _previousRect = _currentRect;
      _currentRect = targetRect;
      _stepCtrl.forward(from: 0);
    }

    // Trigger confetti on finale (once per build of finale step).
    if (step.kind == CoachmarkStepKind.finale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_confettiCtrl.state != ConfettiControllerState.playing) {
          _confettiCtrl.play();
        }
      });
    }

    return Positioned.fill(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // Tap blocker so taps on highlighted widgets don't fire mid-tour.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // swallow
              ),
            ),
            // Animated dim + cutout. (No global BackdropFilter — it would
            // also blur the spotlight area, hurting legibility of the very
            // thing we're trying to show.)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([_glowCtrl, _stepCtrl]),
                builder: (context, _) {
                  final eased = Curves.easeOutCubic.transform(_stepCtrl.value);
                  final animatedRect = (targetRect != null &&
                          _previousRect != null &&
                          eased < 1.0)
                      ? Rect.lerp(
                          _previousRect!.inflate(_kSpotlightPadding),
                          targetRect.inflate(_kSpotlightPadding),
                          eased,
                        )
                      : (targetRect?.inflate(_kSpotlightPadding));

                  return CustomPaint(
                    painter: SpotlightPainter(
                      holeRect: animatedRect,
                      holeRadius: _kSpotlightRadius,
                      dimOpacity: 0.62,
                      dimColor: const Color(0xFF1A1413),
                      glowColor: AppColors.primary,
                      glowProgress: _glowCtrl.value,
                    ),
                  );
                },
              ),
            ),
            // Skip button (top-right). Hidden on finale.
            if (step.kind != CoachmarkStepKind.finale)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: _SkipButton(
                  onTap: () => ref
                      .read(coupleHomeTourControllerProvider.notifier)
                      .skip(),
                ),
              ),
            // Progress dots (top-center).
            Positioned(
              top: MediaQuery.of(context).padding.top + 18,
              left: 0,
              right: 0,
              child: Center(
                child: _ProgressDots(
                  total: steps.length,
                  current: tourState.currentStep,
                ),
              ),
            ),
            // Step content.
            ..._buildStepContent(
              context,
              step,
              targetRect,
              steps.length,
              tourState.currentStep,
            ),
            // Confetti (only finale).
            if (step.kind == CoachmarkStepKind.finale)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiCtrl,
                  blastDirection: math.pi / 2,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.04,
                  numberOfParticles: 22,
                  maxBlastForce: 18,
                  minBlastForce: 8,
                  gravity: 0.25,
                  shouldLoop: false,
                  colors: const [
                    AppColors.primary,
                    AppColors.accentGold,
                    AppColors.accentTeal,
                    AppColors.accentPeach,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStepContent(
    BuildContext context,
    CoachmarkStep step,
    Rect? targetRect,
    int totalSteps,
    int currentStep,
  ) {
    switch (step.kind) {
      case CoachmarkStepKind.welcomeModal:
      case CoachmarkStepKind.infoModal:
      case CoachmarkStepKind.finale:
        return [
          Center(
            child: _ModalCard(
              key: ValueKey('modal_$currentStep'),
              step: step,
              onPrimary: () =>
                  ref.read(coupleHomeTourControllerProvider.notifier).next(),
              isFinale: step.kind == CoachmarkStepKind.finale,
              isWelcome: step.kind == CoachmarkStepKind.welcomeModal,
            ),
          ),
        ];
      case CoachmarkStepKind.spotlight:
        return [
          _SpotlightTooltip(
            key: ValueKey('tooltip_$currentStep'),
            step: step,
            targetRect: targetRect,
            onPrimary: () =>
                ref.read(coupleHomeTourControllerProvider.notifier).next(),
          ),
        ];
    }
  }

  Rect? _findTargetRect(GlobalKey? key) {
    if (key == null) return null;
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    return origin & box.size;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Modal card (welcome / info / finale)
// ────────────────────────────────────────────────────────────────────────────

class _ModalCard extends StatelessWidget {
  final CoachmarkStep step;
  final VoidCallback onPrimary;
  final bool isFinale;
  final bool isWelcome;

  const _ModalCard({
    super.key,
    required this.step,
    required this.onPrimary,
    required this.isFinale,
    required this.isWelcome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.modal),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(26, 32, 26, 24),
              decoration: BoxDecoration(
                color: theme.surface.withValues(
                  alpha: theme.isDarkMode ? 0.92 : 0.96,
                ),
                borderRadius: BorderRadius.circular(AppRadii.modal),
                border: Border.all(
                  color: theme.border.withValues(
                    alpha: theme.isDarkMode ? 0.32 : 0.55,
                  ),
                ),
                boxShadow: theme.modalShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isFinale)
                    _FinaleHeart()
                  else
                    _ModalIllustration(step: step, isWelcome: isWelcome),
                  const SizedBox(height: 22),
                  if (step.eyebrow != null) ...[
                    _Eyebrow(text: step.eyebrow!),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    step.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.9,
                      height: 1.05,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    step.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _PrimaryCta(label: step.primaryCta, onTap: onPrimary),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 260.ms, curve: Curves.easeOutCubic).scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
          duration: 320.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class _ModalIllustration extends StatelessWidget {
  final CoachmarkStep step;
  final bool isWelcome;
  const _ModalIllustration({required this.step, required this.isWelcome});

  @override
  Widget build(BuildContext context) {
    // The "duelo semanal" info modal gets the special VS illustration.
    final isDuel = !isWelcome && step.icon == Icons.emoji_events_rounded;
    if (isDuel) return const _DuelIllustration();

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Icon(
        step.icon ?? Icons.auto_awesome_rounded,
        color: Colors.white,
        size: 42,
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
          begin: 1.0,
          end: 1.04,
          duration: 1800.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _DuelIllustration extends StatelessWidget {
  const _DuelIllustration();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left avatar
          Align(
            alignment: const Alignment(-0.85, 0),
            child: const _DuelAvatar(
              tint: AppColors.primary,
              icon: Icons.person_rounded,
            ).animate().slideX(
                  begin: -0.4,
                  end: 0,
                  duration: 420.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
          // Right avatar
          Align(
            alignment: const Alignment(0.85, 0),
            child: const _DuelAvatar(
              tint: AppColors.accentTeal,
              icon: Icons.favorite_rounded,
            ).animate().slideX(
                  begin: 0.4,
                  end: 0,
                  duration: 420.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
          // VS chip
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentGold,
                  AppColors.accentGold.withValues(alpha: 0.78),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: theme.surface, width: 3),
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.4, 0.4),
                end: const Offset(1, 1),
                duration: 480.ms,
                curve: Curves.easeOutBack,
                delay: 220.ms,
              )
              .then()
              .shimmer(
                duration: 1400.ms,
                color: Colors.white.withValues(alpha: 0.6),
              ),
        ],
      ),
    );
  }
}

class _DuelAvatar extends StatelessWidget {
  final Color tint;
  final IconData icon;
  const _DuelAvatar({required this.tint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: tint.withValues(alpha: 0.45), width: 2),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: tint, size: 32),
    );
  }
}

class _FinaleHeart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.42),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Icon(
        Icons.favorite_rounded,
        color: Colors.white,
        size: 46,
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
          duration: 520.ms,
          curve: Curves.easeOutBack,
        )
        .then()
        .shimmer(
          duration: 1400.ms,
          color: Colors.white.withValues(alpha: 0.55),
        );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Spotlight tooltip
// ────────────────────────────────────────────────────────────────────────────

class _SpotlightTooltip extends StatelessWidget {
  final CoachmarkStep step;
  final Rect? targetRect;
  final VoidCallback onPrimary;

  const _SpotlightTooltip({
    super.key,
    required this.step,
    required this.targetRect,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    // Decide placement: above target if there's room, else below.
    final rect = targetRect;
    final placement = step.placement;

    final tooltip = _TooltipCard(step: step, onPrimary: onPrimary);

    // When target is missing, just center the tooltip.
    if (rect == null) {
      return Center(child: tooltip);
    }

    final spaceAbove = rect.top - safeTop - 80; // reserve room for progress
    final spaceBelow = size.height - rect.bottom - safeBottom - 24;

    final placeAbove = switch (placement) {
      TooltipPlacement.above => true,
      TooltipPlacement.below => false,
      TooltipPlacement.auto => spaceAbove >= spaceBelow,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              left: _kTooltipMargin,
              right: _kTooltipMargin,
              top: placeAbove
                  ? null
                  : (rect.bottom + _kTooltipGap).clamp(
                      safeTop + 80,
                      size.height - 200,
                    ),
              bottom: placeAbove
                  ? (size.height - rect.top + _kTooltipGap)
                      .clamp(safeBottom + 24, size.height - 200)
                      .toDouble()
                  : null,
              child: Center(child: tooltip),
            ),
          ],
        );
      },
    );
  }
}

class _TooltipCard extends StatelessWidget {
  final CoachmarkStep step;
  final VoidCallback onPrimary;
  const _TooltipCard({required this.step, required this.onPrimary});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _kTooltipMaxWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            decoration: BoxDecoration(
              color: theme.surface.withValues(
                alpha: theme.isDarkMode ? 0.92 : 0.97,
              ),
              borderRadius: BorderRadius.circular(AppRadii.xxl),
              border: Border.all(
                color: theme.border.withValues(
                  alpha: theme.isDarkMode ? 0.32 : 0.55,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step.eyebrow != null) ...[
                  _Eyebrow(text: step.eyebrow!),
                  const SizedBox(height: 10),
                ],
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                    height: 1.08,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.body,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                    color: theme.textSecondary,
                  ),
                ),
                if (step.bullets.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ...step.bullets.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _BulletRow(bullet: b),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: _PrimaryCta(
                    label: step.primaryCta,
                    onTap: onPrimary,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 240.ms, curve: Curves.easeOutCubic).slideY(
          begin: 0.04,
          end: 0,
          duration: 320.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _BulletRow extends StatelessWidget {
  final CoachmarkBullet bullet;
  const _BulletRow({required this.bullet});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bullet.tint.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(bullet.icon, color: bullet.tint, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            bullet.text,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary.withValues(alpha: 0.88),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Shared bits: eyebrow, primary CTA, skip button, progress dots
// ────────────────────────────────────────────────────────────────────────────

class _Eyebrow extends StatelessWidget {
  final String text;
  const _Eyebrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool compact;
  const _PrimaryCta({
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padH = compact ? 22.0 : 28.0;
    final padV = compact ? 13.0 : 16.0;
    // Compact CTAs live inside a ClipRRect-wrapped tooltip card. Any drop
    // shadow on the button would be sliced where it meets the card's clip
    // path. The gradient + frosted card already provide enough elevation,
    // so we skip shadows in compact mode.
    final shadows = compact
        ? const <BoxShadow>[]
        : <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.42),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: shadows,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
            ),
          ),
          child: const Text(
            'Saltar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int total;
  final int current;
  const _ProgressDots({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (i) {
          final isActive = i == current;
          final isPast = i < current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : (isPast
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.32)),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          );
        }),
      ),
    );
  }
}
