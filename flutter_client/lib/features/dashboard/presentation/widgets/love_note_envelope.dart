import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/dashboard/domain/models/love_note_model.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';

class LoveNoteEnvelope extends ConsumerStatefulWidget {
  final LoveNoteModel note;
  final String senderName;

  const LoveNoteEnvelope({
    super.key,
    required this.note,
    required this.senderName,
  });

  @override
  ConsumerState<LoveNoteEnvelope> createState() => _LoveNoteEnvelopeState();
}

class _LoveNoteEnvelopeState extends ConsumerState<LoveNoteEnvelope>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _openController;
  late final ConfettiController _confettiController;

  bool _isOpen = false;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _openController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_isOpen || _isDismissing) return;
    HapticFeedback.lightImpact();
    setState(() => _isOpen = true);
    _floatController.stop();
    _openController.forward(from: 0);
    _confettiController.play();
  }

  Future<void> _onClose() async {
    HapticFeedback.lightImpact();
    setState(() => _isDismissing = true);
    await _openController.reverse();
    if (!mounted) return;
    ref.read(loveNotesProvider.notifier).markAsRead(widget.note.id);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: -6,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.06,
            numberOfParticles: 10,
            gravity: 0.14,
            colors: const [
              Color(0xFFFF8A5B),
              Color(0xFFFFB199),
              Color(0xFFFFD5C7),
              Color(0xFF8CB6AE),
              Color(0xFFFFC76B),
            ],
            createParticlePath: _heartPath,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          child: _isOpen
              ? _buildOpenNote()
              : GestureDetector(
                  key: const ValueKey('closedLoveNote'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _onTap,
                  child: _buildClosedEnvelope(),
                ),
        ),
      ],
    );
  }

  Widget _buildClosedEnvelope() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        final pulse = sin(_floatController.value * pi);
        final sway = sin(_floatController.value * pi * 2);

        return Transform.translate(
          offset: Offset(0, pulse * -3),
          child: Transform.rotate(
            angle: sway * 0.025,
            child: SizedBox(
              width: 76,
              height: 58,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(68, 46),
                    painter: _LoveEnvelopePainter(progress: pulse),
                  ),
                  Positioned(
                    top: 9 - (pulse * 2),
                    child: Transform.scale(
                      scale: 0.92 + (pulse * 0.08),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7F0),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                AppColors.accentOrange.withValues(alpha: 0.28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentOrange.withValues(
                                alpha: 0.14,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 12,
                          color: AppColors.accentOrange.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 7,
                    child: Transform.scale(
                      scale: 0.85 + (pulse * 0.18),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentOrange.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    )
        .animate()
        .slideX(
          begin: 0.45,
          end: 0,
          duration: 560.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 260.ms)
        .scaleXY(
          begin: 0.74,
          end: 1,
          duration: 560.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildOpenNote() {
    return AnimatedBuilder(
      animation: _openController,
      builder: (context, child) {
        final eased = Curves.easeOutBack.transform(_openController.value);
        return Opacity(
          opacity: _openController.value,
          child: Transform.scale(
            scale: 0.84 + (eased * 0.16),
            alignment: Alignment.topRight,
            child: child,
          ),
        );
      },
      child: Container(
        key: const ValueKey('openLoveNote'),
        width: 236,
        constraints: const BoxConstraints(maxHeight: 270),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF7),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.accentOrange.withValues(alpha: 0.20),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentOrange.withValues(alpha: 0.14),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 9),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEDE4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_post_office_rounded,
                    size: 16,
                    color: AppColors.accentOrange,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${widget.senderName} te escribió',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5C504C),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _onClose,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: Color(0xFF8B7A73),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Text(
                  widget.note.content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F3835),
                    height: 1.42,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 12,
                    color: AppColors.accentOrange.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Guardado en el hogar',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8B7A73),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Path _heartPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w / 2, h * 0.35);
    path.cubicTo(w * 0.15, 0, -w * 0.25, h * 0.55, w / 2, h);
    path.cubicTo(w * 1.25, h * 0.55, w * 0.85, 0, w / 2, h * 0.35);
    path.close();
    return path;
  }
}

class _LoveEnvelopePainter extends CustomPainter {
  final double progress;

  const _LoveEnvelopePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    final shadowPaint = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.11)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(rrect.shift(const Offset(0, 5)), shadowPaint);

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF7F0), Color(0xFFFFE5D8)],
      ).createShader(rect);
    canvas.drawRRect(rrect, bodyPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.accentOrange.withValues(alpha: 0.20);
    canvas.drawRRect(rrect, borderPaint);

    final seamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFEFB49F).withValues(alpha: 0.78);

    final leftFold = Path()
      ..moveTo(4, size.height * 0.30)
      ..lineTo(size.width * 0.50, size.height * 0.62)
      ..lineTo(size.width - 4, size.height * 0.30);
    canvas.drawPath(leftFold, seamPaint);

    final bottomFold = Path()
      ..moveTo(5, size.height - 5)
      ..lineTo(size.width * 0.50, size.height * 0.53)
      ..lineTo(size.width - 5, size.height - 5);
    canvas.drawPath(bottomFold, seamPaint);

    final flapLift = progress * 5;
    final flapPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFEEE6), Color(0xFFFFD2C1)],
      ).createShader(rect);
    final flap = Path()
      ..moveTo(6, 5 + flapLift)
      ..quadraticBezierTo(
        size.width * 0.50,
        0 - flapLift,
        size.width - 6,
        5 + flapLift,
      )
      ..lineTo(size.width * 0.50, size.height * 0.54 + (progress * 3))
      ..close();
    canvas.drawPath(flap, flapPaint);
    canvas.drawPath(flap, seamPaint);

    final shinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.50);
    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.18),
      Offset(size.width * 0.35, size.height * 0.10),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LoveEnvelopePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
