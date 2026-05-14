import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

enum AppSnackBarType { neutral, success, error, warning, info }

class AppSnackBar {
  static final ValueNotifier<bool> isVisible = ValueNotifier<bool>(false);
  static OverlayEntry? _activeEntry;

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

    final palette = _palette(context, type);
    final hasAction = actionLabel != null && onAction != null;

    _activeEntry?.remove();
    _activeEntry = null;
    isVisible.value = true;

    final media = MediaQuery.of(context);
    final bottomOffset = media.viewInsets.bottom > 0
        ? media.viewInsets.bottom + 16
        : media.viewPadding.bottom + 76;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _AppSnackToast(
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
            isVisible.value = false;
          }
          if (entry.mounted) {
            entry.remove();
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _activeEntry?.remove();
    _activeEntry = null;
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 190),
      reverseDuration: const Duration(milliseconds: 140),
    )..forward();

    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  void _handleAction() {
    widget.onAction?.call();
    unawaited(_dismiss());
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return Positioned(
      left: 18,
      right: 18,
      bottom: widget.bottomOffset,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.18),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            ),
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
                          style: TextStyle(
                            color: palette.foreground,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            height: 1.18,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
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
