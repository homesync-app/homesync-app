# 005 — Aligerar la transición de cambio de tab (FadeIndexedStack)

- **Status**: DONE (2026-07-11)
- **Commit**: b84e65aa
- **Severity**: LOW
- **Category**: Purpose & frequency
- **Estimated scope**: 1 archivo (`app_animations.dart`), 2 ediciones

## Problem

Cambiar de tab en la bottom nav es una acción de decenas de veces por día. Hoy cada cambio reproduce en `FadeIndexedStack` una entrada de **300ms con fade + slide + scale** que reinicia de cero en cada tap. Para acciones tan frecuentes el movimiento debe reducirse drásticamente: el fade+scale corto ya comunica el cambio; el slide vertical agrega viaje visual que se paga cientos de veces por semana.

Código actual (`flutter_client/lib/core/utils/app_animations.dart`):

```dart
// :146 — actual
this.duration = const Duration(milliseconds: 300),
```

```dart
// :223 — actual
return FadeTransition(
  opacity: drive,
  child: SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(drive),
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.985, end: 1).animate(drive),
      child: TickerMode(
        enabled: isActive,
        child: widget.children[i],
      ),
    ),
  ),
);
```

## Target

Duración `AppMotion.normal` (220ms) y sin `SlideTransition` — queda fade + scale:

```dart
// :146 — target
this.duration = AppMotion.normal,
```

```dart
// :223 — target
return FadeTransition(
  opacity: drive,
  child: ScaleTransition(
    scale: Tween<double>(begin: 0.985, end: 1).animate(drive),
    child: TickerMode(
      enabled: isActive,
      child: widget.children[i],
    ),
  ),
);
```

## Repo conventions to follow

- `AppMotion.normal` (= 220ms) vive en `flutter_client/lib/core/theme/app_design_tokens.dart:169`; `app_animations.dart` ya lo importa.
- **REGLA CRÍTICA de este repo** (bug documentado de remount con teclado): los wrappers entre el shell y las pantallas deben mantener una forma de árbol ESTABLE. Está permitido quitar el `SlideTransition` porque se quita para TODOS los hijos en TODOS los estados (la forma sigue siendo idéntica entre hijos activos/inactivos y entre rebuilds). Está PROHIBIDO hacerlo condicional (`if (algo) SlideTransition(...) else child`) — eso remonta el subtree y rompe el foco de los TextField.
- Trailing commas obligatorias.

## Steps

1. En `flutter_client/lib/core/utils/app_animations.dart`, cambiar el default del constructor de `FadeIndexedStack` de `const Duration(milliseconds: 300)` a `AppMotion.normal` (quitar el `const` del parámetro si el analyzer lo exige: `this.duration = AppMotion.normal,` es válido porque `AppMotion.normal` es `const`).
2. En el `build` de `_FadeIndexedStackState`, eliminar el wrapper `SlideTransition` (y su `Tween<Offset>`) dejando `FadeTransition → ScaleTransition → TickerMode` exactamente como en Target. El resto del método (lazy mount, `_visitedIndices`, `AlwaysStoppedAnimation`) no se toca.
3. Confirmar que el único consumidor (`main_screen.dart:609`) no pasa `duration:` explícita (en b84e65aa no la pasa — usa el default).
4. `dart format` sobre el archivo.

## Boundaries

- NO tocar la lógica de montaje perezoso (`_visitedIndices`, `_childCount`) ni `TickerMode`.
- NO tocar `forward(from: 0.0)` en `didUpdateWidget` — cada cambio de tab es una entrada nueva; reiniciar es correcto.
- NO tocar la transición de página global ni la bottom nav (`custom_bottom_nav.dart`).
- NO condicionar la forma del árbol (ver REGLA CRÍTICA arriba).
- Si el código no coincide con los excerpts (drift desde b84e65aa), PARAR y reportar.

## Verification

- **Mecánica**: `cd flutter_client && flutter analyze` (~4 min) — cero issues nuevos.
- **Feel check**: correr la app y confirmar:
  - Cambiar de tab se siente inmediato: un fade+asentamiento corto, sin deslizamiento vertical.
  - Martillar 2 tabs alternadamente 10 veces rápido: nunca hay flash blanco ni parpadeo raro, y cada tab conserva su posición de scroll.
  - **Regresión del teclado (trap conocida del repo)**: ir a Compras, tocar el TextField de agregar ítem: el teclado abre y SE QUEDA abierto (no se abre/cierra solo). Escribir, cambiar de tab y volver: el estado se conserva.
- **Done when**: cambio de tab a 220ms fade+scale, sin slide, teclado de Compras estable, analyze limpio.
