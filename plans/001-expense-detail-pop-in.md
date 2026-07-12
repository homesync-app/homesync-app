# 001 — Reemplazar el elasticOut de 500ms del detalle de gasto por un pop-in crisp

- **Status**: DONE (2026-07-11)
- **Commit**: b84e65aa
- **Severity**: HIGH
- **Category**: Easing & duration
- **Estimated scope**: 2 archivos (~10 ediciones puntuales)

## Problem

El sheet de detalle de gasto (`ExpenseDetailSheet`) se abre decenas de veces por día. Su contenido entra con `animateScaleIn`, que es un scale de **500ms con `Curves.elasticOut`** (rebote elástico con varias oscilaciones), encadenado con delays de **100/200/300ms**. El monto del gasto — lo que el usuario abrió el sheet a ver — recién asienta ~800ms después de abrir. Las animaciones de UI deben quedar por debajo de 300ms; el rebote elástico se reserva para celebraciones raras (pantalla de ganador semanal), no para UI frecuente.

Helper actual:

```dart
// flutter_client/lib/core/utils/app_animations.dart:114 — actual
Widget animateScaleIn({int delay = 0}) {
  return animate()
      .scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1, 1),
        duration: 500.ms,
        delay: delay.ms,
        curve: Curves.elasticOut,
      )
      .fadeIn(duration: 300.ms, delay: delay.ms);
}
```

Call sites problemáticos (todos en `flutter_client/lib/features/expenses/presentation/widgets/expense_detail_sheet.dart`):

```dart
// :227 — botón de editar
).animateScaleIn(delay: 100),
// :283 — ícono de categoría
).animateScaleIn(delay: 200),
// :298 — título
).animateEntrance(delay: 250),
// :309 — EL MONTO (el contenido principal llega último y rebotando)
).animateScaleIn(delay: 300),
// :331 — chips de metadata
).animateEntrance(delay: 350),
// :339 — bloque descripción
).animateEntrance(delay: 150),
// :483 — bloque de acciones del pie
).animateEntrance(delay: 400),
```

## Target

1. Nuevo helper `animatePopIn` en la extensión `AppAnimationsExtension` de `flutter_client/lib/core/utils/app_animations.dart`, inmediatamente después de `animateScaleIn` (NO borrar `animateScaleIn`: lo siguen usando las celebraciones de `weekly_winner_screen.dart`, `members_screen.dart` y los avatares de home — esos quedan como están):

```dart
/// Entrada crisp para contenido de sheets/cards frecuentes: scale sutil sin
/// rebote. Para celebraciones raras usar [animateScaleIn] (elastic).
Widget animatePopIn({int delay = 0}) {
  return animate()
      .fadeIn(duration: 180.ms, delay: delay.ms, curve: Curves.easeOutCubic)
      .scale(
        begin: const Offset(0.96, 0.96),
        end: const Offset(1, 1),
        duration: 220.ms,
        delay: delay.ms,
        curve: Curves.easeOutCubic,
      );
}
```

2. En `expense_detail_sheet.dart`, reemplazar EXACTAMENTE estas 7 llamadas (el resto del archivo no se toca; la de la línea 181 `.animateEntrance(),` sin delay queda igual). El stagger queda en pasos de 30–80ms y el monto entra temprano:

| Línea (commit b84e65aa) | Actual | Nuevo |
| --- | --- | --- |
| 227 | `).animateScaleIn(delay: 100),` | `).animatePopIn(delay: 80),` |
| 283 | `).animateScaleIn(delay: 200),` | `).animatePopIn(delay: 0),` |
| 298 | `).animateEntrance(delay: 250),` | `).animateEntrance(delay: 30),` |
| 309 | `).animateScaleIn(delay: 300),` | `).animatePopIn(delay: 60),` |
| 331 | `).animateEntrance(delay: 350),` | `).animateEntrance(delay: 80),` |
| 339 | `).animateEntrance(delay: 150),` | `).animateEntrance(delay: 100),` |
| 483 | `).animateEntrance(delay: 400),` | `).animateEntrance(delay: 120),` |

Cada string "Actual" es única en el archivo: buscar y reemplazar el string exacto, no la línea por número.

## Repo conventions to follow

- Los helpers de animación viven en la extensión `AppAnimationsExtension` de `flutter_client/lib/core/utils/app_animations.dart` y usan la API de `flutter_animate` (`animate().fadeIn(...).scale(...)`, duraciones con `.ms`).
- Ejemplar del look correcto ya existente en el repo: `_CelebrationDialog` en `app_animations.dart:410` — `fadeIn(duration: 160.ms, curve: Curves.easeOutCubic).scale(begin: Offset(0.96, 0.96), duration: 220.ms, curve: Curves.easeOutCubic)`. `animatePopIn` replica exactamente esa sensación.
- Trailing commas obligatorias (lint `require_trailing_commas`).

## Steps

1. En `flutter_client/lib/core/utils/app_animations.dart`, agregar el método `animatePopIn` (código de Target) dentro de `extension AppAnimationsExtension on Widget`, después de `animateScaleIn` (línea ~124).
2. En `flutter_client/lib/features/expenses/presentation/widgets/expense_detail_sheet.dart`, aplicar los 7 reemplazos exactos de la tabla de Target.
3. Correr `dart format` sobre los 2 archivos tocados.

## Boundaries

- NO tocar `animateScaleIn` ni sus otros call sites (`weekly_winner_screen.dart`, `members_screen.dart`, `home_couple_view.dart`, `home_solo_view.dart`).
- NO tocar `.animateEntrance(),` de la línea 181 (sin delay).
- NO cambiar estructura/markup del sheet — solo las llamadas de animación.
- NO agregar dependencias.
- Si algún string "Actual" no aparece exactamente una vez en el archivo (drift desde b84e65aa), PARAR y reportar en vez de improvisar.

## Verification

- **Mecánica**: `cd flutter_client && flutter analyze` (tarda ~4 min en este repo) — cero issues nuevos respecto a la base.
- **Feel check**: correr la app, abrir un gasto desde la lista de Finanzas y confirmar:
  - El monto es visible y quieto antes de ~300ms; nada rebota ni oscila.
  - El orden de llegada se siente: ícono → título → monto → chips, con pasos apenas perceptibles (30–80ms), nunca "en fila india".
  - Abrir y cerrar el sheet 5 veces seguidas rápido: ninguna entrada se siente lenta ni pega saltos.
  - La pantalla de ganador semanal (`weekly_winner_screen`) conserva su rebote elástico (no debe cambiar).
- **Done when**: los 7 reemplazos aplicados, `animatePopIn` existe con los valores exactos, analyze limpio.
