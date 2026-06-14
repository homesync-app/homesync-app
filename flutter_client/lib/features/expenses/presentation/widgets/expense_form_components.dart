import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

class ExpenseFormHeader extends StatelessWidget {
  final bool isEditing;
  final bool isIncome;
  final VoidCallback onClose;
  final VoidCallback? onDelete;

  const ExpenseFormHeader({
    super.key,
    required this.isEditing,
    required this.isIncome,
    required this.onClose,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final title = isEditing
        ? (isIncome
            ? t.expensesFormHeaderEditIncome
            : t.expensesFormHeaderEditExpense)
        : (isIncome
            ? t.expensesFormHeaderNewIncome
            : t.expensesFormHeaderNewExpense);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: t.commonClose,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: onClose,
              ),
              if (isEditing)
                IconButton(
                  tooltip: t.commonDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.accentRed,
                  ),
                  onPressed: onDelete,
                )
              else
                const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseSectionIntro extends StatelessWidget {
  final String eyebrow;
  final String title;

  const ExpenseSectionIntro({
    super.key,
    required this.eyebrow,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class ExpenseTypeOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ExpenseTypeOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected ? Colors.white : theme.textSecondary,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              fontSize: 16,
              letterSpacing: isSelected ? -0.2 : 0,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class ExpenseActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const ExpenseActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: theme.border.withValues(alpha: 0.85)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowBase.withValues(
                alpha: theme.isDarkMode ? 0.18 : 0.02,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseInfoBox extends StatelessWidget {
  final String text;
  final Color color;

  const ExpenseInfoBox({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color == theme.textSecondary
              ? theme.textSecondary
              : color.withValues(alpha: 0.82),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class ExpenseAmountField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool showScanAction;
  final bool isScanningReceipt;
  final bool hasScanResult;
  final int ocrRevealTrigger;
  final VoidCallback? onOcrRevealComplete;
  final VoidCallback? onScanReceipt;

  const ExpenseAmountField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.showScanAction = false,
    this.isScanningReceipt = false,
    this.hasScanResult = false,
    this.ocrRevealTrigger = 0,
    this.onOcrRevealComplete,
    this.onScanReceipt,
  });

  @override
  State<ExpenseAmountField> createState() => _ExpenseAmountFieldState();
}

class _ExpenseAmountFieldState extends State<ExpenseAmountField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;
  double _ocrStartAmount = 0;
  double _ocrTargetAmount = 0;
  String _ocrTargetText = '';
  bool _isAnimatingOcrAmount = false;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
      value: 1,
    )
      ..addListener(_syncAnimatedOcrAmount)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_isAnimatingOcrAmount && _ocrTargetText.isNotEmpty) {
            widget.controller.value = TextEditingValue(
              text: _ocrTargetText,
              selection: TextSelection.collapsed(offset: _ocrTargetText.length),
            );
          }
          _isAnimatingOcrAmount = false;
          widget.onOcrRevealComplete?.call();
        }
      });
  }

  @override
  void didUpdateWidget(covariant ExpenseAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ocrRevealTrigger != oldWidget.ocrRevealTrigger &&
        widget.ocrRevealTrigger > 0) {
      // didUpdateWidget corre DURANTE el build del padre. Mutar el controller
      // acá dispara el listener del Form ancestro → setState() durante build.
      // Diferimos el arranque del count-up al post-frame, cuando el árbol ya
      // está montado y mutar el controller es seguro.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startOcrAmountCountUp();
        _revealController.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _revealController.removeListener(_syncAnimatedOcrAmount);
    _revealController.dispose();
    super.dispose();
  }

  void _startOcrAmountCountUp() {
    final targetText = widget.controller.text;
    final target = _parseAmountText(targetText);
    if (target <= 0) {
      _isAnimatingOcrAmount = false;
      return;
    }

    final current = _parseAmountText(widget.controller.text);
    _ocrStartAmount = current > 0 && current != target ? current : 0;
    _ocrTargetAmount = target;
    _ocrTargetText = targetText;
    _isAnimatingOcrAmount = true;

    final initialText = _formatAnimatedAmount(_ocrStartAmount);
    widget.controller.value = TextEditingValue(
      text: initialText,
      selection: TextSelection.collapsed(offset: initialText.length),
    );
  }

  void _syncAnimatedOcrAmount() {
    if (!_isAnimatingOcrAmount || _ocrTargetAmount <= 0) return;
    final eased = Curves.easeOutCubic.transform(_revealController.value);
    final value =
        _ocrStartAmount + (_ocrTargetAmount - _ocrStartAmount) * eased;
    final formatted = _formatAnimatedAmount(value);
    if (widget.controller.text == formatted) return;
    widget.controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  double _parseAmountText(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  String _formatAnimatedAmount(double value) {
    final hasDecimals = _ocrTargetText.contains(',');
    if (!hasDecimals) {
      return NumberFormat.decimalPattern('es_ES').format(value.round());
    }

    final clamped = value.clamp(0, _ocrTargetAmount);
    final intPart = clamped.truncate();
    final decPart = ((clamped - intPart) * 100).round().abs();
    final intFormatted = NumberFormat('#,##0', 'es_ES').format(intPart);
    return '$intFormatted,${decPart.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.82),
          width: 1,
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.showScanAction)
            Positioned(
              left: 0,
              top: 34,
              child: _ReceiptScanButton(
                isScanningReceipt: widget.isScanningReceipt,
                hasScanResult: widget.hasScanResult,
                onTap: widget.onScanReceipt,
              ),
            ),
          Column(
            children: [
              Text(
                'Monto total',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(width: double.infinity, height: 42),
                  AnimatedBuilder(
                    animation: _revealController,
                    builder: (context, child) {
                      final curved = Curves.easeOutCubic.transform(
                        _revealController.value,
                      );
                      return Transform.translate(
                        offset: Offset(0, (1 - curved) * 4),
                        child: Transform.scale(
                          scale: 0.985 + curved * 0.015,
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10, top: 2),
                          child: Text(
                            '\$',
                            style: TextStyle(
                              color: theme.textMuted,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            autofocus: true,
                            controller: widget.controller,
                            onChanged: widget.onChanged,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                color: theme.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                              filled: false,
                              fillColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              AnimatedBuilder(
                animation: _revealController,
                builder: (context, _) {
                  final value = Curves.easeOutCubic.transform(
                    _revealController.value,
                  );
                  return Container(
                    width: 72 + value * 18,
                    height: 1,
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(
                        alpha: 0.12 + value * 0.12,
                      ),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptScanButton extends StatefulWidget {
  final bool isScanningReceipt;
  final bool hasScanResult;
  final VoidCallback? onTap;

  const _ReceiptScanButton({
    required this.isScanningReceipt,
    required this.hasScanResult,
    required this.onTap,
  });

  @override
  State<_ReceiptScanButton> createState() => _ReceiptScanButtonState();
}

class _ReceiptScanButtonState extends State<_ReceiptScanButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    if (widget.isScanningReceipt) _scanController.repeat();
  }

  @override
  void didUpdateWidget(covariant _ReceiptScanButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanningReceipt && !_scanController.isAnimating) {
      _scanController.repeat();
    } else if (!widget.isScanningReceipt && _scanController.isAnimating) {
      _scanController.stop();
      _scanController.value = 0;
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.onTap != null;
    final accent =
        widget.hasScanResult ? AppColors.accentGreen : AppColors.accentBlue;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 42,
        height: 42,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color:
              accent.withValues(alpha: widget.isScanningReceipt ? 0.14 : 0.10),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: accent.withValues(
              alpha: widget.isScanningReceipt ? 0.34 : 0.18,
            ),
          ),
          boxShadow: [
            if (widget.isScanningReceipt || widget.hasScanResult)
              BoxShadow(
                color: accent.withValues(
                  alpha: widget.isScanningReceipt ? 0.16 : 0.10,
                ),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isScanningReceipt)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    final pulse = math.sin(_scanController.value * math.pi * 2);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(
                          alpha: 0.035 + ((pulse + 1) * 0.018),
                        ),
                      ),
                      child: CustomPaint(
                        painter: _ScanningBorderPainter(
                          progress: _scanController.value,
                          color: AppColors.accentBlue,
                          radius: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                final pulse = widget.isScanningReceipt
                    ? math.sin(_scanController.value * math.pi * 2)
                    : 0.0;
                return Transform.scale(
                  scale: 1 + (pulse * 0.035),
                  child: child,
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Icon(
                  widget.hasScanResult
                      ? Icons.check_rounded
                      : widget.isScanningReceipt
                          ? Icons.document_scanner_rounded
                          : Icons.document_scanner_outlined,
                  key: ValueKey(
                    '${widget.hasScanResult}-${widget.isScanningReceipt}',
                  ),
                  color: isActive || widget.hasScanResult
                      ? accent
                      : accent.withValues(alpha: 0.55),
                  size: widget.hasScanResult ? 23 : 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanningBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double radius;

  const _ScanningBorderPainter({
    required this.progress,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1.5),
      Radius.circular(radius),
    );
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.16);
    canvas.drawRRect(rrect, basePaint);

    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final length = metric.length;
    final start = length * progress;
    final segmentLength = length * 0.34;
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.62);

    void drawSegment(double from, double to) {
      canvas.drawPath(metric.extractPath(from, to), activePaint);
    }

    if (start + segmentLength <= length) {
      drawSegment(start, start + segmentLength);
    } else {
      drawSegment(start, length);
      drawSegment(0, (start + segmentLength) - length);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanningBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.radius != radius;
  }
}

class ExpenseScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const ExpenseScanButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.07),
          border: Border.all(
            color: AppColors.accentBlue.withValues(alpha: 0.25),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(icon, size: 18, color: AppColors.accentBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseTitleField extends StatelessWidget {
  final bool isIncome;
  final TextEditingController controller;

  const ExpenseTitleField({
    super.key,
    required this.isIncome,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.border.withValues(alpha: 0.82)),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          Icon(
            isIncome
                ? Icons.account_balance_wallet_outlined
                : Icons.shopping_bag_outlined,
            color: theme.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: isIncome
                    ? '¿De qué es el ingreso? (Opcional)'
                    : '¿Qué compraste? (Opcional)',
                hintStyle: TextStyle(
                  color: theme.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                filled: false,
                fillColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
