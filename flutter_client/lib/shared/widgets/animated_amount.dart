
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Tabular figures keep every digit the same width, so amounts don't jitter
/// horizontally while animating and columns of numbers stay aligned.
const List<FontFeature> kTabularFigures = [FontFeature.tabularFigures()];

extension TabularNumberStyle on TextStyle {
  /// Use on any [TextStyle] that renders money, points or counters.
  TextStyle get tabular => copyWith(fontFeatures: kTabularFigures);
}

/// Rolling count-up for money and point amounts.
///
/// On first build the number rolls in from zero (hero amounts) or shows the
/// value directly ([animateFromZero] false). On later value changes it always
/// animates from the previous value, never restarting from zero. Digits render
/// with tabular figures so the text doesn't wobble while rolling.
class AnimatedAmount extends StatefulWidget {
  final double value;

  /// Locale used for digit grouping, e.g. `es_AR`.
  final String locale;
  final TextStyle? style;
  final int decimalDigits;

  /// Rendered before the number with the same style (e.g. `'$ '` or `'+ $ '`).
  final String prefix;
  final bool animateFromZero;
  final Duration duration;
  final Curve curve;

  /// Formateo completo del valor animado (p.ej. `currency.format`). Cuando se
  /// pasa, reemplaza al formatter interno y a [prefix] — útil para monedas
  /// con símbolo como sufijo ("20.000 $").
  final String Function(double value)? format;

  const AnimatedAmount({
    super.key,
    required this.value,
    required this.locale,
    this.style,
    this.decimalDigits = 0,
    this.prefix = '',
    this.animateFromZero = true,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutExpo,
    this.format,
  });

  @override
  State<AnimatedAmount> createState() => _AnimatedAmountState();
}

class _AnimatedAmountState extends State<AnimatedAmount> {
  late double _begin;

  @override
  void initState() {
    super.initState();
    _begin = widget.animateFromZero ? 0 : widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _begin = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = (widget.style ?? DefaultTextStyle.of(context).style).tabular;
    final formatter = widget.decimalDigits == 0
        ? NumberFormat.decimalPattern(widget.locale)
        : NumberFormat.decimalPatternDigits(
            locale: widget.locale,
            decimalDigits: widget.decimalDigits,
          );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _begin, end: widget.value),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, animated, _) {
        if (widget.format != null) {
          return Text(widget.format!(animated), style: style);
        }
        final number = widget.decimalDigits == 0
            ? formatter.format(animated.round())
            : formatter.format(animated);
        return Text('${widget.prefix}$number', style: style);
      },
    );
  }
}
