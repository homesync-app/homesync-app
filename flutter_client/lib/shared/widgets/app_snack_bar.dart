import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:motor/motor.dart';

enum AppSnackBarType { neutral, success, error, warning, info }

class AppSnackBar {
  static final ValueNotifier<bool> isVisible = ValueNotifier<bool>(false);
  static OverlayEntry? _activeEntry;
  static String? _activeMessage;
  static GlobalKey<_AppSnackToastState>? _activeToastKey;

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.neutral,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // Mensaje duplicado: en vez de re-crear la pill, la viva tiembla con un
    // impulso de spring (cue de bunpod) y renueva su countdown.
    final activeToast = _activeToastKey?.currentState;
    if (_activeMessage == message &&
        activeToast != null &&
        !activeToast.isDismissing) {
      activeToast.shakeAndRestart();
      return;
    }

    final palette = _palette(context, type);
    final hasAction = actionLabel != null && onAction != null;

    _activeEntry?.remove();
    _activeEntry = null;
    isVisible.value = true;

    final media = MediaQuery.of(context);
    final bottomOffset = media.viewInsets.bottom > 0
        ? media.viewInsets.bottom + 16
        : media.viewPadding.bottom + 76;

    final toastKey = GlobalKey<_AppSnackToastState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _AppSnackToast(
        key: toastKey,
        message: message,
        palette: palette,
        hasAction: hasAction,
        actionLabel: actionLabel,
        duration: duration ?? _durationFor(type, hasAction),
        bottomOffset: bottomOffset,
        onAction: onAction,
        onDismissed: () {
          if (_activeEntry == entry) {
            _activeEntry = null;
            _activeMessage = null;
            _activeToastKey = null;
            isVisible.value = false;
          }
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    _activeEntry = entry;
    _activeMessage = message;
    _activeToastKey = toastKey;
    overlay.insert(entry);
  }

  static void dismiss() {
    _activeEntry?.remove();
    _activeEntry = null;
    _activeMessage = null;
    _activeToastKey = null;
    isVisible.value = false;
  }

  static Duration _durationFor(AppSnackBarType type, bool hasAction) {
    if (hasAction) return const Duration(seconds: 4);
    return switch (type) {
      AppSnackBarType.error => const Duration(milliseconds: 3200),
      AppSnackBarType.warning => const Duration(milliseconds: 2400),
      _ => const Duration(milliseconds: 1500),
    };
  }

  static _SnackPalette _palette(BuildContext context, AppSnackBarType type) {
    final theme = context.theme;
    final isDark = theme.isDarkMode;

    Color tint(Color color) => isDark
        ? Color.alphaBlend(color.withValues(alpha: 0.20), theme.elevatedSurface)
        : Color.alphaBlend(color.withValues(alpha: 0.08), Colors.white);

    Color border(Color color) => color.withValues(alpha: isDark ? 0.28 : 0.18);

    return switch (type) {
      AppSnackBarType.success => _SnackPalette(
          background: tint(AppColors.sage),
          foreground:
              isDark ? const Color(0xFFE9F3EF) : const Color(0xFF45665E),
          border: border(AppColors.sage),
          action: AppColors.sage,
          icon: Icons.check_rounded,
        ),
      AppSnackBarType.error => _SnackPalette(
          background: tint(AppColors.error),
          foreground:
              isDark ? const Color(0xFFFFEDEC) : const Color(0xFF8E3D38),
          border: border(AppColors.error),
          action: AppColors.error,
          icon: Icons.error_outline_rounded,
        ),
      AppSnackBarType.warning => _SnackPalette(
          background: tint(AppColors.warning),
          foreground:
              isDark ? const Color(0xFFFFF2CC) : const Color(0xFF775D1C),
          border: border(AppColors.warning),
          action: AppColors.warning,
          icon: Icons.info_outline_rounded,
        ),
      AppSnackBarType.info => _SnackPalette(
          background: tint(AppColors.info),
          foreground:
              isDark ? const Color(0xFFE7F3F1) : const Color(0xFF45665E),
          border: border(AppColors.info),
          action: AppColors.info,
          icon: Icons.info_outline_rounded,
        ),
      AppSnackBarType.neutral => _SnackPalette(
          background: isDark ? theme.elevatedSurface : Colors.white,
          foreground: theme.textPrimary,
          border: theme.border.withValues(alpha: isDark ? 0.35 : 0.75),
          action: theme.primary,
          icon: Icons.check_rounded,
        ),
    };
  }
}

class _AppSnackToast extends StatefulWidget {
  final String message;
  final _SnackPalette palette;
  final bool hasAction;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final double bottomOffset;
  final VoidCallback onDismissed;

  const _AppSnackToast({
    super.key,
    required this.message,
    required this.palette,
    required this.hasAction,
    required this.actionLabel,
    required this.onAction,
    required this.duration,
    required this.bottomOffset,
    required this.onDismissed,
  });

  @override
  State<_AppSnackToast> createState() => _AppSnackToastState();
}

class _AppSnackToastState extends State<_AppSnackToast>
    with TickerProviderStateMixin {
  // Recorrido de entrada/salida desde debajo del borde inferior, en px.
  static const double _travel = 140;
  // Umbral de drag/velocidad para cerrar al soltar; corto a propósito para
  // que un flick rápido alcance.
  static const double _dismissOffset = 24;
  static const double _dismissVelocity = 300;
  // Impulso lateral del shake por mensaje duplicado, en px/s.
  static const double _shakeVelocity = 600;

  // Offset vertical del dedo; vuelve a 0 con spring si no pasó el umbral.
  late final AnimationController _drag = AnimationController.unbounded(
    vsync: this,
  )..value = 0;

  // Offset horizontal del shake; descansa en 0 y solo se mueve por impulso.
  late final AnimationController _shake = AnimationController.unbounded(
    vsync: this,
  )..value = 0;

  bool _visible = true;
  bool _removing = false;
  Timer? _timer;

  bool get isDismissing => _removing;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _drag.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_removing) return;
    _removing = true;
    _timer?.cancel();
    _drag.stop();
    if (mounted) setState(() => _visible = false);
    // Sale de la lista una vez asentado el spring de salida.
    Timer(const Duration(milliseconds: 400), () {
      if (mounted) widget.onDismissed();
    });
  }

  /// Cue de mensaje duplicado: impulso lateral sobre un spring que descansa
  /// en 0 — la pill tiembla y se asienta con física real. También reinicia
  /// el countdown: el mensaje acaba de demostrar que sigue vigente.
  void shakeAndRestart() {
    if (_removing) return;
    _timer?.cancel();
    _timer = Timer(widget.duration, _dismiss);
    AppHaptics.selection();
    _shake.animateWith(
      SpringSimulation(
        const MaterialSpringMotion.expressiveSpatialFast().description,
        0,
        0,
        _shakeVelocity,
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    // Sostener la pill pausa el auto-dismiss.
    _timer?.cancel();
    _drag.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _drag.value = (_drag.value + details.delta.dy).clamp(0.0, _travel * 2);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    if (_drag.value > _dismissOffset || velocity > _dismissVelocity) {
      _dismiss();
      return;
    }
    _settleBack(velocity);
  }

  void _settleBack(double velocity) {
    if (_removing) return;
    _drag.animateWith(
      SpringSimulation(
        const MaterialSpringMotion.standardSpatialFast().description,
        _drag.value,
        0,
        velocity,
      ),
    );
    _timer = Timer(widget.duration, _dismiss);
  }

  void _handleAction() {
    widget.onAction?.call();
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Positioned(
      left: 18,
      right: 18,
      bottom: widget.bottomOffset,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        // Entrada con overshoot expresivo desde abajo; salida con spring
        // estándar (calmo). El drag y el shake se suman encima del spring.
        child: SingleMotionBuilder(
          motion: _visible
              ? const MaterialSpringMotion.expressiveSpatialFast()
              : const MaterialSpringMotion.standardSpatialFast(),
          value: _visible ? 0.0 : 1.0,
          from: reduceMotion ? null : 1.0,
          active: !reduceMotion,
          builder: (context, t, child) => AnimatedBuilder(
            animation: Listenable.merge([_drag, _shake]),
            builder: (context, _) => Transform.translate(
              offset: Offset(_shake.value, t * _travel + _drag.value),
              child: Opacity(
                // El fade solo acompaña la salida; clampeado para no vibrar
                // con el overshoot del spring.
                opacity: _removing ? (1 - t.clamp(0.0, 1.0)) : 1,
                child: child,
              ),
            ),
            child: child,
          ),
          child: GestureDetector(
            onVerticalDragStart: _onDragStart,
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            onVerticalDragCancel: () => _settleBack(0),
            child: Material(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: palette.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    10,
                    widget.hasAction ? 6 : 14,
                    10,
                  ),
                  child: Row(
                    children: [
                      Icon(palette.icon, size: 17, color: palette.foreground),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyStrong.copyWith(
                            color: palette.foreground,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (widget.hasAction) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _handleAction,
                          style: TextButton.styleFrom(
                            foregroundColor: palette.action,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: const Size(0, 34),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnackPalette {
  final Color background;
  final Color foreground;
  final Color border;
  final Color action;
  final IconData icon;

  const _SnackPalette({
    required this.background,
    required this.foreground,
    required this.border,
    required this.action,
    required this.icon,
  });
}
