import 'package:flutter/material.dart';
import 'package:homesync_client/shared/widgets/vendor/material_shapes/material_shapes.dart';
import 'package:motor/motor.dart';

/// Catálogo curado de siluetas M3 Expressive para acentos de HomeSync.
///
/// Usar estos alias semánticos (no [MaterialShapes] directo en features) para
/// que el lenguaje de formas se mantenga consistente: una forma = un
/// significado en toda la app.
abstract final class AppShapes {
  /// Estado "logrado / completado" (el burst clásico de M3 Expressive).
  static RoundedPolygon get success => MaterialShapes.cookie7Sided;

  /// Celebración grande (confeti, récords).
  static RoundedPolygon get celebration => MaterialShapes.softBurst;

  /// Acento de pareja (favoritos, notas de amor).
  static RoundedPolygon get love => MaterialShapes.heart;

  /// Neutros para morphs (reposo → activo).
  static RoundedPolygon get circle => MaterialShapes.circle;
  static RoundedPolygon get square => MaterialShapes.square;

  /// Decorativos para ilustración/fondos.
  static RoundedPolygon get flower => MaterialShapes.flower;
  static RoundedPolygon get gem => MaterialShapes.gem;
  static RoundedPolygon get sunny => MaterialShapes.sunny;
  static RoundedPolygon get clover => MaterialShapes.clover4Leaf;

  /// Border interpolado entre dos siluetas; tolera el overshoot de los
  /// springs expresivos devolviendo el extremo cuando `t` sale de [0, 1].
  static ShapeBorder morphBorder(
    RoundedPolygon from,
    RoundedPolygon to,
    double t,
  ) {
    final fromBorder = MaterialShapeBorder(shape: from);
    if (t <= 0) return fromBorder;
    final toBorder = MaterialShapeBorder(shape: to);
    if (t >= 1) return toBorder;
    return fromBorder.lerpTo(toBorder, t)!;
  }
}

/// Recorta [child] con una silueta que morfea [from] → [to] sobre física de
/// spring cuando [active] cambia. Con animaciones reducidas salta directo a
/// la silueta final sin animar.
class AppShapeMorph extends StatelessWidget {
  final bool active;
  final RoundedPolygon from;
  final RoundedPolygon to;
  final Motion motion;

  /// Valor inicial del spring al montarse (0 = arranca en [from] y morfea
  /// hacia el estado actual). Null = aparece ya asentado, sin animar.
  final double? fromValue;

  final Widget child;

  const AppShapeMorph({
    super.key,
    required this.active,
    required this.from,
    required this.to,
    this.motion = const MaterialSpringMotion.expressiveSpatialFast(),
    this.fromValue,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return SingleMotionBuilder(
      motion: motion,
      value: active ? 1.0 : 0.0,
      from: fromValue,
      active: !reduceMotion,
      builder: (context, t, child) => ClipPath(
        clipper: ShapeBorderClipper(
          shape: AppShapes.morphBorder(from, to, t),
        ),
        child: child,
      ),
      child: child,
    );
  }
}

/// Chip sólido con silueta expresiva y contenido centrado (checks, conteos,
/// mini-íconos). El equivalente "con forma" de un badge circular.
class AppShapedBadge extends StatelessWidget {
  final RoundedPolygon shape;
  final Color color;
  final double size;
  final Widget? child;

  const AppShapedBadge({
    super.key,
    required this.shape,
    required this.color,
    this.size = 26,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: color,
        shape: MaterialShapeBorder(shape: shape),
      ),
      child: child,
    );
  }
}
