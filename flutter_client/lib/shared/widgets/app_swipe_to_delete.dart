import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';

/// Swipe-to-delete with premium drag feedback.
///
/// Wrap list rows with this instead of a raw [Dismissible]: the trash icon
/// pops as the drag crosses the dismiss threshold and a warning haptic fires
/// at that exact moment (and a soft tick when backing out), so the user can
/// feel whether releasing will delete.
class AppSwipeToDelete extends StatefulWidget {
  /// Key for the underlying [Dismissible] (use the row's stable id).
  final Key dismissibleKey;
  final Widget child;

  /// Optional confirmation (e.g. a dialog). Return false/null to cancel.
  final Future<bool?> Function()? confirm;
  final VoidCallback onDeleted;
  final double borderRadius;

  const AppSwipeToDelete({
    super.key,
    required this.dismissibleKey,
    required this.child,
    required this.onDeleted,
    this.confirm,
    this.borderRadius = 22,
  });

  @override
  State<AppSwipeToDelete> createState() => _AppSwipeToDeleteState();
}

class _AppSwipeToDeleteState extends State<AppSwipeToDelete> {
  bool _reached = false;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: widget.dismissibleKey,
      direction: DismissDirection.endToStart,
      onUpdate: (details) {
        if (details.reached == _reached) return;
        setState(() => _reached = details.reached);
        if (details.reached) {
          AppHaptics.warning();
        } else {
          AppHaptics.tap();
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.error.withValues(alpha: 0.55),
              AppColors.error.withValues(alpha: 0.92),
            ],
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: AnimatedScale(
          scale: _reached ? 1.18 : 0.88,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutBack,
          child: const Icon(
            Icons.delete_sweep_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      confirmDismiss:
          widget.confirm == null ? null : (_) async => await widget.confirm!(),
      onDismissed: (_) => widget.onDeleted(),
      child: widget.child,
    );
  }
}
