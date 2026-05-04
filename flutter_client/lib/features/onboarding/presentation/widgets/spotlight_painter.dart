import 'package:flutter/material.dart';

/// Paints the dimmed backdrop with a rounded-rectangle hole around the
/// currently spotlit target. Optionally draws a soft glow ring around the
/// hole that the caller animates from outside.
class SpotlightPainter extends CustomPainter {
  /// Hole rect in *overlay* coordinates. Pass null to paint a flat backdrop
  /// (used for modal steps that don't spotlight a widget).
  final Rect? holeRect;
  final double holeRadius;
  final double dimOpacity;
  final Color dimColor;
  final Color glowColor;

  /// Drives the breathing glow ring. 0..1.
  final double glowProgress;

  const SpotlightPainter({
    required this.holeRect,
    required this.holeRadius,
    required this.dimOpacity,
    required this.dimColor,
    required this.glowColor,
    required this.glowProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;
    final dimPaint = Paint()..color = dimColor.withValues(alpha: dimOpacity);

    final hole = holeRect;
    if (hole == null) {
      canvas.drawRect(fullRect, dimPaint);
      return;
    }

    final rrect = RRect.fromRectAndRadius(hole, Radius.circular(holeRadius));

    // 1) Outer dim with the hole punched out.
    canvas.save();
    canvas.clipPath(
      Path()
        ..addRect(fullRect)
        ..addRRect(rrect)
        ..fillType = PathFillType.evenOdd,
    );
    canvas.drawRect(fullRect, dimPaint);
    canvas.restore();

    // 2) Subtle inner shadow on the hole edge so the cutout feels carved
    //    rather than stuck on top.
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.10);
    canvas.drawRRect(rrect, edgePaint);

    // 3) Breathing glow ring (two soft strokes, offset by glowProgress).
    final t = (glowProgress.clamp(0.0, 1.0));
    final ringExpand = 6.0 + 8.0 * t; // pulses outward
    final ringRect = hole.inflate(ringExpand);
    final ringRrect = RRect.fromRectAndRadius(
      ringRect,
      Radius.circular(holeRadius + ringExpand),
    );

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = glowColor.withValues(alpha: (1 - t) * 0.55)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + 6 * t);
    canvas.drawRRect(ringRrect, ringPaint);

    // Crisp inner accent — stays put, just below the hole edge.
    final crispRing = RRect.fromRectAndRadius(
      hole.inflate(2),
      Radius.circular(holeRadius + 2),
    );
    final crispPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = glowColor.withValues(alpha: 0.85);
    canvas.drawRRect(crispRing, crispPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter old) {
    return old.holeRect != holeRect ||
        old.holeRadius != holeRadius ||
        old.dimOpacity != dimOpacity ||
        old.dimColor != dimColor ||
        old.glowColor != glowColor ||
        old.glowProgress != glowProgress;
  }
}
