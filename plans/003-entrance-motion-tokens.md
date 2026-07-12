# 003 — Consolidar las entradas sobre los tokens de AppMotion

- **Status**: DONE (2026-07-11)
- **Commit**: b84e65aa
- **Severity**: MEDIUM
- **Category**: Cohesion & tokens
- **Estimated scope**: 3 archivos (helpers), sin sweep masivo

## Problem

Existen tokens de motion (`AppMotion.fast/normal/slow/standard` en `flutter_client/lib/core/theme/app_design_tokens.dart:167`), pero los sistemas de entrada no los usan y sus valores derivaron: `animateEntrance` = 400ms, `AppFeedEntryMotion` = 420ms, `FadeIndexedStack` = 300ms, transición de página = curvas propias. En total hay 153 `duration:` hardcodeadas contra 36 referencias a `AppMotion`. Cuatro números distintos para la misma idea ("entrada de contenido") hacen que la app se sienta sutilmente incoherente y que cada ajuste futuro requiera cazar valores.

Código actual:

```dart
// flutter_client/lib/core/utils/app_animations.dart:98 — actual
Widget animateEntrance({int delay = 0}) {
  return animate()
      .fadeIn(duration: 400.ms, delay: delay.ms, curve: Curves.easeOutCubic)
      .slideY(
        begin: 0.1,
        end: 0,
        duration: 400.ms,
        delay: delay.ms,
        curve: Curves.easeOutCubic,
      );
}
```

```dart
// flutter_client/lib/shared/widgets/app_feed_entry_motion.dart:24 — actual
this.duration = const Duration(milliseconds: 420),
```

```dart
// flutter_client/lib/shared/widgets/app_feed_entry_motion.dart:40 — actual
curve: delay == Duration.zero
    ? Curves.easeOutCubic
    : Interval(
        delay.inMilliseconds / totalMs,
        1,
        curve: Curves.easeOutCubic,
      ),
```

## Target

Una sola fuente de verdad: **entrada de contenido = `AppMotion.slow` (360ms) + `AppMotion.standard` (easeOutCubic)**; micro-entradas (pop-in) = `AppMotion.fast`/`AppMotion.normal`. 360ms queda dentro del presupuesto para entradas de bloques de contenido y ya existe como token — no inventar tokens paralelos.

```dart
// app_animations.dart — target
Widget animateEntrance({int delay = 0}) {
  return animate()
      .fadeIn(
        duration: AppMotion.slow,
        delay: delay.ms,
        curve: AppMotion.standard,
      )
      .slideY(
        begin: 0.1,
        end: 0,
        duration: AppMotion.slow,
        delay: delay.ms,
        curve: AppMotion.standard,
      );
}
```

```dart
// app_animations.dart — target (animatePopIn, creado por el plan 001)
Widget animatePopIn({int delay = 0}) {
  return animate()
      .fadeIn(
        duration: AppMotion.fast,
        delay: delay.ms,
        curve: AppMotion.standard,
      )
      .scale(
        begin: const Offset(0.96, 0.96),
        end: const Offset(1, 1),
        duration: AppMotion.normal,
        delay: delay.ms,
        curve: AppMotion.standard,
      );
}
```

```dart
// app_feed_entry_motion.dart — target
this.duration = AppMotion.slow,
```

y sus dos `Curves.easeOutCubic` (líneas 41 y 45) pasan a `AppMotion.standard`.

## Repo conventions to follow

- Tokens en `AppMotion` (`app_design_tokens.dart:167`): `fast` = 160ms, `normal` = 220ms, `slow` = 360ms, `standard` = `Curves.easeOutCubic`. Son `const`, así que sirven como default de constructor (`this.duration = AppMotion.slow`).
- Ejemplar de uso correcto ya en el repo: `flutter_client/lib/features/stats/presentation/widgets/stats_tabs.dart:402` — `LineChart(duration: AppMotion.slow, curve: AppMotion.standard, ...)`.
- Convención del repo para migraciones de tokens (documentada en la migración de radii/spacing 2026-06): **solo matches exactos, nunca snapear valores cercanos a ciegas**.
- Trailing commas obligatorias; tras ediciones correr `dart format`.

## Steps

1. `flutter_client/lib/core/utils/app_animations.dart`: reescribir `animateEntrance` con el target (el archivo ya importa `app_design_tokens.dart`).
2. Mismo archivo: reescribir `animatePopIn` (agregado por el plan 001) con el target. Si `animatePopIn` no existe, PARAR — el plan 001 debe ejecutarse antes.
3. `flutter_client/lib/shared/widgets/app_feed_entry_motion.dart`: cambiar el default del constructor a `AppMotion.slow` y las dos `Curves.easeOutCubic` a `AppMotion.standard`. Agregar `import 'package:homesync_client/core/theme/app_design_tokens.dart';`.
4. `flutter_client/lib/core/theme/app_design_tokens.dart`: sobre `class AppMotion` agregar un doc comment que fije el contrato para futuro código:

```dart
/// Escala de motion de HomeSync.
/// - [fast] 160ms: feedback de press, micro-fades.
/// - [normal] 220ms: pop-in de contenido, switchers, cambio de tab.
/// - [slow] 360ms: entrada de bloques/pantallas, draw-ins cortos.
/// Curva por defecto: [standard]. Los draw-ins de charts y las
/// celebraciones pueden exceder la escala deliberadamente.
```

5. `dart format` sobre los archivos tocados.

## Boundaries

- NO hacer sweep masivo de las 153 `Duration(` hardcodeadas — este plan consolida solo los helpers compartidos. (Los valores 700–900ms de charts, count-ups y celebraciones son deliberados; no tocarlos.)
- NO tocar `animateScaleIn` (celebraciones) ni `FadeIndexedStack` (lo ajusta el plan 005).
- NO tocar `shared/widgets/vendor/**` ni `shared/widgets/portal_labs/**`.
- NO cambiar `AppMotion.fast/normal/slow` de valor.
- Si `animateEntrance` o `AppFeedEntryMotion` no coinciden con los excerpts (drift), PARAR y reportar.

## Verification

- **Mecánica**: `cd flutter_client && flutter analyze` (~4 min) — cero issues nuevos.
- **Feel check**: correr la app y confirmar:
  - Home (couple y solo): las cards siguen entrando con fade+drift, apenas más rápido (360ms vs 400/420ms), sin cortes ni pops.
  - El feed con `AppFeedEntryMotion` (entradas escalonadas) conserva su stagger; solo cambia la duración base.
  - El sheet de detalle de gasto (plan 001) no se sintió afectado: pop-in sigue crisp.
- **Done when**: los 3 helpers leen exclusivamente de `AppMotion`, doc comment agregado, analyze limpio.
