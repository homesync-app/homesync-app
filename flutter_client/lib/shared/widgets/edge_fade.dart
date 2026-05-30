import 'package:flutter/widgets.dart';

/// Fades the edges of a scrollable to hint that there's more content.
///
/// Long lists aren't obviously scrollable — items just sit there flush to the
/// edge. A soft alpha fade at the start/end signals "keep scrolling" (idea from
/// flutterpro.design "Make lists feel scrollable").
///
/// The mask is alpha-only via [BlendMode.dstIn], so it works the same in light
/// and dark mode and over any background.
///
/// Usage:
/// ```dart
/// EdgeFade(
///   axis: Axis.horizontal,
///   fadeStart: false, // only hint the trailing edge
///   child: ListView(scrollDirection: Axis.horizontal, ...),
/// )
/// ```
class EdgeFade extends StatelessWidget {
  final Widget child;
  final Axis axis;
  final bool fadeStart;
  final bool fadeEnd;

  /// Fraction of the box over which each edge fades (0..0.5).
  final double extent;

  const EdgeFade({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.fadeStart = true,
    this.fadeEnd = true,
    this.extent = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    // Nothing to fade — skip the (cheap but non-zero) saveLayer ShaderMask does.
    if (!fadeStart && !fadeEnd) return child;

    final bool isVertical = axis == Axis.vertical;
    final double startStop = extent.clamp(0.0, 0.5);
    final double endStop = (1.0 - startStop).clamp(0.5, 1.0);

    const Color opaque = Color(0xFFFFFFFF);
    const Color clear = Color(0x00FFFFFF);

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
          end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
          colors: <Color>[
            fadeStart ? clear : opaque,
            opaque,
            opaque,
            fadeEnd ? clear : opaque,
          ],
          stops: <double>[0.0, startStop, endStop, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
