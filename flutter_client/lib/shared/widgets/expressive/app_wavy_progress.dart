import 'package:flutter/material.dart';
import 'package:homesync_client/shared/widgets/vendor/material_wavy_progress_indicator/material_wavy_progress_indicator.dart';

/// Barra de progreso determinada estilo M3 Expressive: el tramo completado
/// ondula suavemente mientras la meta está viva y se aplana sola al acercarse
/// al 100% (la rampa vive en el indicador vendoreado).
///
/// Sustituye a [LinearProgressIndicator] en superficies premium (metas de
/// ahorro, duelo). Con animaciones reducidas la onda queda estática (no se
/// desplaza), conservando la silueta.
class AppWavyProgress extends StatelessWidget {
  final double value;
  final Color color;
  final Color? trackColor;
  final double strokeWidth;
  final double amplitude;
  final double wavelength;
  final double waveSpeed;
  final String? semanticsLabel;

  const AppWavyProgress({
    super.key,
    required this.value,
    required this.color,
    this.trackColor,
    this.strokeWidth = 5,
    this.amplitude = 2.2,
    this.wavelength = 42,
    this.waveSpeed = 26,
    this.semanticsLabel,
  });

  /// Variante fina para listas densas (compactas) — misma onda, menos alto.
  const AppWavyProgress.compact({
    super.key,
    required this.value,
    required this.color,
    this.trackColor,
    this.strokeWidth = 3.5,
    this.amplitude = 1.5,
    this.wavelength = 30,
    this.waveSpeed = 20,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return WavyLinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      color: color,
      trackColor: trackColor ?? color.withValues(alpha: 0.14),
      stopIndicatorColor: color,
      strokeWidth: strokeWidth,
      amplitude: amplitude,
      wavelength: wavelength,
      waveSpeed: reduceMotion ? 0 : waveSpeed,
      semanticsLabel: semanticsLabel,
    );
  }
}
