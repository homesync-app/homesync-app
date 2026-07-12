import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homesync_client/shared/widgets/expressive/app_shape_morph.dart';
import 'package:homesync_client/shared/widgets/vendor/material_shapes/material_shapes.dart';
import 'package:motor/motor.dart';

/// Fondo decorativo tipo "channel wall" de bunpod: una grilla full-bleed de
/// celdas cuadradas que, tras una espera escalonada por celda, morfean —una
/// sola vez— de cuadrado a una silueta M3 Expressive, abriendo el espacio
/// negativo entre ellas. Una vez asentadas, quedan quietas.
///
/// Pensado como textura de fondo (colores en tintes muy suaves de la paleta):
/// no captura toques y con animaciones reducidas renderiza directo la silueta
/// final.
class AppShapeMosaic extends StatelessWidget {
  /// Tintes que van rotando por celda (ya con su alpha aplicado).
  final List<Color> colors;

  /// Tamaño objetivo de celda; el número de columnas se elige para acercarse.
  final double targetTile;

  const AppShapeMosaic({
    super.key,
    required this.colors,
    this.targetTile = 118,
  });

  // Siluetas por las que rotan las celdas.
  static final List<RoundedPolygon> _shapes = <RoundedPolygon>[
    MaterialShapes.cookie7Sided,
    MaterialShapes.clover4Leaf,
    MaterialShapes.sunny,
    MaterialShapes.gem,
    MaterialShapes.softBurst,
    MaterialShapes.flower,
    MaterialShapes.pentagon,
    MaterialShapes.puffy,
  ];

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cols = (constraints.maxWidth / targetTile).round().clamp(3, 5);
          final cell = constraints.maxWidth / cols;
          final rows = (constraints.maxHeight / cell).ceil();

          return Stack(
            children: [
              for (var row = 0; row < rows; row++)
                for (var col = 0; col < cols; col++)
                  Positioned(
                    left: col * cell,
                    top: row * cell,
                    width: cell,
                    height: cell,
                    child: _MosaicTile(
                      key: ValueKey(row * cols + col),
                      color: colors[(row * cols + col) % colors.length],
                      shape: _shapes[(row * cols + col) % _shapes.length],
                      // Espera pseudo-aleatoria pero determinista por celda,
                      // para que el morph recorra el muro sin patrón obvio.
                      delay: Duration(
                        milliseconds: 160 + (row * cols + col) * 37 % 520,
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _MosaicTile extends StatefulWidget {
  final Color color;
  final RoundedPolygon shape;
  final Duration delay;

  const _MosaicTile({
    super.key,
    required this.color,
    required this.shape,
    required this.delay,
  });

  @override
  State<_MosaicTile> createState() => _MosaicTileState();
}

class _MosaicTileState extends State<_MosaicTile> {
  bool _settled = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _settled = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return AppShapeMorph(
      active: _settled || reduceMotion,
      from: AppShapes.square,
      to: widget.shape,
      motion: const MaterialSpringMotion.expressiveSpatialDefault(),
      child: ColoredBox(color: widget.color),
    );
  }
}
