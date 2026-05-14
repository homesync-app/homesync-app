import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_design_tokens.dart';
import '../../../../core/theme/app_theme_extension.dart';

// In-app notification banner.
// Shows a compact, tappable notification above the bottom navigation.
class InAppNotificationBanner extends StatefulWidget {
  final VoidCallback onTap;

  const InAppNotificationBanner({super.key, required this.onTap});

  @override
  InAppNotificationBannerState createState() => InAppNotificationBannerState();
}

class InAppNotificationBannerState extends State<InAppNotificationBanner>
    with TickerProviderStateMixin {
  static const _displayDuration = Duration(milliseconds: 2800);
  static const _enterDuration = Duration(milliseconds: 220);
  static const _exitDuration = Duration(milliseconds: 150);

  late final AnimationController _controller;
  late final AnimationController _progressController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  Timer? _dismissTimer;
  String _title = '';
  String _body = '';
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _enterDuration,
      reverseDuration: _exitDuration,
    );
    _progressController = AnimationController(
      vsync: this,
      duration: _displayDuration,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.standard),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.standard),
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.standard),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _progressController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Called by MainScreen when a new notification arrives.
  void show({required String title, required String body}) {
    if (!mounted) return;

    _dismissTimer?.cancel();
    setState(() {
      _title = title;
      _body = body;
      _visible = true;
    });

    _controller.duration = _enterDuration;
    _controller.reverseDuration = _exitDuration;
    _progressController.reset();
    _controller.forward(from: 0);
    _startAutoDismiss();
  }

  void _startAutoDismiss() {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery?.accessibleNavigation ?? false) {
      _progressController.stop();
      return;
    }

    final remaining = _displayDuration * (1 - _progressController.value);
    _dismissTimer = Timer(remaining, () {
      if (mounted && _visible) _dismiss();
    });
    _progressController.forward();
  }

  void _pauseAutoDismiss() {
    _dismissTimer?.cancel();
    _progressController.stop();
  }

  void _resumeAutoDismiss() {
    _dismissTimer?.cancel();
    if (!_visible || _progressController.isCompleted) return;
    _startAutoDismiss();
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    if (!_visible) return;

    _controller.duration = _exitDuration;
    _controller.reverseDuration = _exitDuration;
    _controller.reverse().then((_) {
      if (!mounted) return;
      _progressController.reset();
      setState(() => _visible = false);
    });
  }

  void _dismissAfterSwipe() {
    _dismissTimer?.cancel();
    _progressController.reset();
    if (mounted) setState(() => _visible = false);
  }

  void _openNotifications() {
    _dismiss();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final theme = context.theme;
    final isAccessibleNavigation =
        MediaQuery.maybeOf(context)?.accessibleNavigation ?? false;
    if (isAccessibleNavigation) {
      _dismissTimer?.cancel();
      _progressController.stop();
    }

    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Semantics(
                  liveRegion: true,
                  button: true,
                  label: _body.isEmpty ? _title : '$_title. $_body',
                  child: GestureDetector(
                    onLongPressStart: (_) => _pauseAutoDismiss(),
                    onLongPressEnd: (_) => _resumeAutoDismiss(),
                    child: Dismissible(
                      key: ValueKey('$_title-$_body'),
                      direction: DismissDirection.down,
                      resizeDuration: null,
                      onDismissed: (_) => _dismissAfterSwipe(),
                      child: Material(
                        color: theme.elevatedSurface,
                        borderRadius: AppRadii.control,
                        child: InkWell(
                          borderRadius: AppRadii.control,
                          onTap: _openNotifications,
                          onHighlightChanged: (isHighlighted) {
                            if (isHighlighted) {
                              _pauseAutoDismiss();
                            } else {
                              _resumeAutoDismiss();
                            }
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 64),
                            decoration: BoxDecoration(
                              borderRadius: AppRadii.control,
                              border: Border.all(
                                color: theme.border.withValues(
                                  alpha: theme.isDarkMode ? 0.7 : 1,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowBase.withValues(
                                    alpha: theme.isDarkMode ? 0.28 : 0.09,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 12, 8, 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: theme.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          Icons.notifications_none_rounded,
                                          color: theme.primary,
                                          size: 21,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _title,
                                              style: TextStyle(
                                                color: theme.textPrimary,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (_body.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                _body,
                                                style: TextStyle(
                                                  color: theme.textSecondary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  height: 1.2,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: MaterialLocalizations.of(
                                          context,
                                        ).closeButtonTooltip,
                                        onPressed: _dismiss,
                                        icon: Icon(
                                          Icons.close_rounded,
                                          color: theme.textMuted,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isAccessibleNavigation)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: AnimatedBuilder(
                                      animation: _progressController,
                                      builder: (context, child) {
                                        return FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: 1 -
                                              _progressController.value
                                                  .clamp(0, 1),
                                          child: child,
                                        );
                                      },
                                      child: Container(
                                        height: 2,
                                        color: theme.primary.withValues(
                                          alpha: theme.isDarkMode ? 0.55 : 0.38,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
