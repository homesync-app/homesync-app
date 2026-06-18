import 'package:flutter/material.dart';
import 'package:homesync_client/core/errors/error_messages.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/shared/widgets/inline_error_banner.dart';

/// Confirmation dialog for settling the shared balance ("Equilibrar").
///
/// Extracted from `HomeCoupleView` so it can be widget-tested in isolation and
/// so the choreography (submitting → success badge → auto-dismiss, or inline
/// error) lives in one place. It owns ALL of its transient state; the host only
/// provides the copy plus two callbacks:
///   * [onConfirm] performs the settlement and THROWS on failure.
///   * [onSettled] runs host side effects (optimistic balance, success toast)
///     once, right after the dialog has popped on success.
///
/// Failures are shown INLINE (never via a background snackbar that would render
/// behind the modal barrier) and run through [friendlyErrorMessage] so a raw
/// stack trace can never reach the user.
class SettlementConfirmDialog extends StatefulWidget {
  const SettlementConfirmDialog({
    super.key,
    required this.titleText,
    required this.amountText,
    required this.directionText,
    required this.bodyText,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.doneBadgeText,
    required this.errorTextBuilder,
    required this.onConfirm,
    this.onSettled,
  });

  final String titleText;
  final String amountText;
  final String directionText;
  final String bodyText;
  final String confirmLabel;
  final String cancelLabel;
  final String doneBadgeText;

  /// Wraps a user-friendly message into the localized "could not settle: {msg}"
  /// template (typically `AppLocalizations.homeCoupleSettlementError`).
  final String Function(String friendlyMessage) errorTextBuilder;

  /// Performs the settlement. Must throw / complete with an error on failure.
  final Future<void> Function() onConfirm;

  /// Host side effects after a successful settle + dismiss (optimistic balance,
  /// success toast). Called at most once.
  final VoidCallback? onSettled;

  @override
  State<SettlementConfirmDialog> createState() =>
      _SettlementConfirmDialogState();
}

class _SettlementConfirmDialogState extends State<SettlementConfirmDialog> {
  bool _isSubmitting = false;
  bool _showSuccess = false;
  String? _errorMessage;

  Future<void> _confirm() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm();
      if (!mounted) return;
      AppHaptics.success();
      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });

      await Future<void>.delayed(const Duration(milliseconds: 420));
      // `mounted` here is the dialog's own lifecycle (a separate route), so a
      // rebuild of the host view can't strand the dialog open — it pops as long
      // as the dialog itself is still on screen.
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSettled?.call();
    } catch (e) {
      if (!mounted) return;
      // Show the failure INSIDE the dialog. A background snackbar renders behind
      // the modal barrier (invisible); friendlyErrorMessage strips raw stack
      // traces / Failure type prefixes — the full detail stays in the logs.
      setState(() {
        _isSubmitting = false;
        _errorMessage = widget.errorTextBuilder(friendlyErrorMessage(e));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.modal),
            border: Border.all(color: theme.border.withValues(alpha: 0.52)),
            boxShadow: theme.modalShadow,
          ),
          // Scrollable so the dialog never overflows on short screens or when a
          // long error message is shown.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: theme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        widget.titleText,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text(
                    widget.amountText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainer.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: theme.border.withValues(alpha: 0.58),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sync_alt_rounded,
                          color: theme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            widget.directionText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.bodyText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  // The whole dialog scrolls (see SingleChildScrollView above),
                  // so a long error wraps freely without overflowing.
                  InlineErrorBanner(message: _errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                        ),
                        child: Text(
                          widget.cancelLabel,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _confirm,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              _showSuccess ? AppColors.sage : theme.primary,
                          disabledBackgroundColor:
                              _showSuccess ? AppColors.sage : theme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: _isSubmitting
                              ? const SizedBox(
                                  key: ValueKey('loading'),
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : _showSuccess
                                  ? Row(
                                      key: const ValueKey('success'),
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(widget.doneBadgeText),
                                      ],
                                    )
                                  : Text(
                                      widget.confirmLabel,
                                      key: const ValueKey('idle'),
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
