# 002 — Respetar "reducir movimiento" del OS en loops ambientales y entradas

- **Status**: DONE (2026-07-11)
- **Commit**: b84e65aa
- **Severity**: MEDIUM
- **Category**: Accessibility
- **Estimated scope**: ~8 archivos

## Problem

La app ignora el setting de accesibilidad del OS "quitar/reducir animaciones" (`MediaQuery.disableAnimations`). Solo un archivo lo respeta (`premium_animated_avatar.dart`); otros 5 chequean `accessibleNavigation`, que detecta lector de pantalla pero NO el setting de reduce-motion. Resultado: con reduce-motion activado, estos loops infinitos siguen moviéndose para siempre:

```dart
// flutter_client/lib/features/dashboard/presentation/widgets/love_note_envelope.dart:39 — actual
_floatController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 2600),
)..repeat(reverse: true);
```

```dart
// flutter_client/lib/shared/widgets/user_avatar.dart:344 (_AnimatedAvatarState) — actual
_controller = AnimationController(
  vsync: this,
  duration: const Duration(seconds: 2),
)..repeat(reverse: true);
```

```dart
// flutter_client/lib/shared/widgets/user_avatar.dart (~:782, _PremiumAvatarMotionState) — actual
_controller = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 3600),
)..repeat(reverse: true);
```

```dart
// flutter_client/lib/features/onboarding/presentation/widgets/coachmark_overlay.dart:49 — actual
_glowCtrl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1600),
)..repeat();
```

```dart
// flutter_client/lib/features/onboarding/presentation/widgets/coachmark_overlay.dart:407 — actual
).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
      begin: 1.0,
      end: 1.04,
      duration: 1800.ms,
      curve: Curves.easeInOut,
    );
```

Además, reduce-motion no significa "cero animación": los fades cortos y los indicadores de carga (shimmer, spinner) se conservan; lo que se apaga es el movimiento posicional y los loops decorativos.

## Target

1. Un helper único en `AppMotion` (`flutter_client/lib/core/theme/app_design_tokens.dart`, la clase termina en la línea 178):

```dart
/// true cuando el OS pide reducir movimiento o hay lector de pantalla
/// activo: los loops ambientales quedan quietos y las entradas se vuelven
/// fade puro. No apagar indicadores de carga ni fades de comprensión.
static bool reduce(BuildContext context) {
  final media = MediaQuery.maybeOf(context);
  if (media == null) return false;
  return media.disableAnimations || media.accessibleNavigation;
}
```

2. Los 4 controllers de loops de arriba dejan de arrancar en `initState` y pasan a gestionarse en `didChangeDependencies` (donde `MediaQuery` ya es accesible y reacciona si el setting cambia en vivo), quedando quietos en `value = 0` bajo reduce-motion.

3. El `.animate(onPlay: ...)` del coachmark se saltea entero bajo reduce-motion (el ícono se muestra estático).

4. Los 5 chequeos existentes de `accessibleNavigation` pasan a usar `AppMotion.reduce(context)` para que también cubran reduce-motion.

## Repo conventions to follow

- **Ejemplar a imitar** (ya correcto en el repo): `flutter_client/lib/shared/widgets/premium_animated_avatar.dart:135` lee `MediaQuery.maybeDisableAnimationsOf(context)` en `didChangeDependencies` y su `_updateBreathing()` (línea 280) arranca/frena el `repeat` según un flag `_reduceMotion`. Copiar ese patrón.
- Tokens de motion viven en `AppMotion` (`app_design_tokens.dart`); el helper nuevo va ahí, no en un archivo nuevo.
- Trailing commas obligatorias (lint `require_trailing_commas`).

## Steps

1. **`app_design_tokens.dart`**: agregar el método `reduce` (código de Target) al final de `class AppMotion` (antes del cierre en :178). El archivo ya importa `package:flutter/material.dart`.

2. **`love_note_envelope.dart`**: quitar `..repeat(reverse: true)` de la línea 42. Agregar en `_LoveNoteEnvelopeState`:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (AppMotion.reduce(context)) {
    _floatController.stop();
    _floatController.value = 0;
  } else if (!_isOpen && !_isDismissing && !_floatController.isAnimating) {
    _floatController.repeat(reverse: true);
  }
}
```

   El archivo ya importa `app_design_tokens.dart`.

3. **`user_avatar.dart` — `_AnimatedAvatarState` (:335)**: quitar `..repeat(reverse: true)` de la línea 347. Agregar:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (AppMotion.reduce(context)) {
    _controller.stop();
    _controller.value = 0;
  } else if (!_controller.isAnimating) {
    _controller.repeat(reverse: true);
  }
}
```

   (Con `value = 0` el avatar queda a escala 1.0 y el anillo dorado queda visible fijo con alpha 1 — la señal "te toca" se conserva sin latir.) Verificar que el archivo importe `app_design_tokens.dart`; si no, agregar el import.

4. **`user_avatar.dart` — `_PremiumAvatarMotionState` (~:772)**: mismo patrón exacto del paso 3 sobre su `_controller` (quitar `..repeat(reverse: true)`, agregar el mismo `didChangeDependencies`). Quieto en `value = 0` ⇒ offset 0, scale 0.995, glow mínimo: correcto.

5. **`coachmark_overlay.dart` (:49)**: quitar `..repeat()` de `_glowCtrl` y agregar el mismo `didChangeDependencies` (con `repeat()` sin `reverse`). Verificar/agregar import de `app_design_tokens.dart`.

6. **`coachmark_overlay.dart` (:407)**: el método que retorna el ícono animado debe saltear la animación bajo reduce-motion. Extraer el `Container(... child: Icon(...))` a una variable `icon` y retornar:

```dart
if (AppMotion.reduce(context)) return icon;
return icon.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
      begin: 1.0,
      end: 1.04,
      duration: 1800.ms,
      curve: Curves.easeInOut,
    );
```

   (El método es de un `State`/widget con `context` disponible; si fuera un helper sin context, pasarlo como parámetro desde `build`.)

7. **Swaps de `accessibleNavigation` → `AppMotion.reduce(context)`** (mantener la misma semántica del branch, solo cambiar la condición):
   - `flutter_client/lib/shared/widgets/app_feed_entry_motion.dart:33` — `if (media?.accessibleNavigation ?? false) return child;` ⇒ `if (AppMotion.reduce(context)) return child;` (borrar la variable `media` si queda sin uso).
   - `flutter_client/lib/features/dashboard/presentation/widgets/notification_bell.dart:60` — `if (count > 0 && !(media?.accessibleNavigation ?? false))` ⇒ `if (count > 0 && !AppMotion.reduce(context))`.
   - `flutter_client/lib/features/tasks/presentation/screens/tasks_screen.dart:793` — `if (!isFinalTodayTask || (media?.accessibleNavigation ?? false))` ⇒ `if (!isFinalTodayTask || AppMotion.reduce(context))`.
   - `flutter_client/lib/features/dashboard/presentation/widgets/in_app_notification_banner.dart:97` y `:159` — reemplazar cada lectura de `accessibleNavigation` por `AppMotion.reduce(context)`.
   - En cada archivo, agregar el import de `app_design_tokens.dart` si falta y borrar variables `media` que queden muertas.

8. Correr `dart format` sobre los archivos tocados.

## Boundaries

- NO tocar `shimmer_loading.dart`, `app_loader.dart`, `splash_screen.dart`, la línea de escaneo de `expense_form_components.dart` ni nada bajo `shared/widgets/vendor/**` o `shared/widgets/portal_labs/**` — son indicadores de carga/estado o código vendoreado.
- NO tocar `premium_animated_avatar.dart` — ya lo hace bien.
- NO cambiar `animatePulse` en `app_animations.dart` (extensión sin context; queda fuera de este plan).
- NO quitar haptics ni fades de opacidad — reduce-motion apaga movimiento, no feedback.
- Si un excerpt "actual" no coincide con el código (drift desde b84e65aa), PARAR y reportar.

## Verification

- **Mecánica**: `cd flutter_client && flutter analyze` (~4 min) — cero issues nuevos.
- **Feel check**: en un dispositivo/emulador Android: Ajustes → Accesibilidad → "Quitar animaciones" ON, relanzar la app y confirmar:
  - El sobre de love note queda quieto (sin flotar ni rotar); al tocarlo se abre igual.
  - El avatar "te toca" muestra el anillo dorado fijo, sin latido.
  - El coachmark de onboarding no pulsa.
  - El shimmer de carga y los spinners SIGUEN animando (no se apagan).
  - Con el setting OFF, todo vuelve a moverse como antes.
- **Done when**: todos los sitios listados gateados con `AppMotion.reduce`, comportamiento verificado con el setting ON y OFF, analyze limpio.
