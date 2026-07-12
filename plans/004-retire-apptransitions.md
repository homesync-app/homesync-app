# 004 — Retirar las rutas legacy AppTransitions y usar la transición global

- **Status**: DONE (2026-07-11)
- **Commit**: b84e65aa
- **Severity**: LOW
- **Category**: Cohesion
- **Estimated scope**: 3 archivos, 3 call sites + 1 clase borrada

## Problem

La app tiene una transición de página brandeada y global (`HomeSyncPageTransitionsBuilder` en `flutter_client/lib/core/theme/app_page_transitions.dart`, cableada vía `ThemeData.pageTransitionsTheme`): fade + drift + scale con `reverseCurve` correcto, y Cupertino nativo en iOS. Pero 3 navegaciones la esquivan usando la clase legacy `AppTransitions` (`flutter_client/lib/core/utils/app_animations.dart:14-93`), que además tiene defectos propios: `slideHorizontal` es un slide lateral completo de 320ms **sin `reverseCurve`** (el pop reproduce la curva easeOut al revés ⇒ la salida arranca lenta) y un fade que parte de 0.7. Notificaciones y Ajustes abren con una metáfora de movimiento distinta al resto de la app.

Call sites actuales:

```dart
// flutter_client/lib/features/dashboard/presentation/screens/main_screen.dart:685 — actual
Navigator.push(
  context,
  AppTransitions.slideUp(
    SettingsScreen(
      onLogout: () {
        _notifService.dispose();
      },
    ),
  ),
);
```

```dart
// flutter_client/lib/features/dashboard/presentation/screens/main_screen.dart:704 — actual
Navigator.push(
  context,
  AppTransitions.slideHorizontal(page: const NotificationsScreen()),
);
```

```dart
// flutter_client/lib/features/dashboard/presentation/screens/modes/home_friends_view.dart:189 — actual
await Navigator.push(
  context,
  AppTransitions.slideHorizontal(page: const NotificationsScreen()),
);
```

## Target

Las 3 navegaciones usan `MaterialPageRoute`, que hereda automáticamente la transición global del theme (y el swipe-back nativo en iOS):

```dart
// main_screen.dart — target (Settings)
Navigator.push(
  context,
  MaterialPageRoute<void>(
    builder: (_) => SettingsScreen(
      onLogout: () {
        _notifService.dispose();
      },
    ),
  ),
);
```

```dart
// main_screen.dart — target (Notifications)
Navigator.push(
  context,
  MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
);
```

```dart
// home_friends_view.dart — target
await Navigator.push(
  context,
  MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
);
```

Y la clase `AppTransitions` completa (líneas 14–93 de `app_animations.dart`, desde `class AppTransitions {` hasta su `}` de cierre, inclusive) se borra.

## Repo conventions to follow

- La transición global vive en `app_page_transitions.dart` y se aplica sola a cualquier `MaterialPageRoute`/ruta material — no hace falta pasar nada.
- Ejemplar en el repo de navegación que ya hereda la transición global: cualquier `Navigator.push(context, MaterialPageRoute(...))` existente (hay varios; p.ej. buscar `MaterialPageRoute` en `lib/features/`).
- Trailing commas obligatorias.

## Steps

1. `main_screen.dart`: aplicar los 2 reemplazos de Target (los strings "actual" son únicos en el archivo).
2. `home_friends_view.dart`: aplicar el reemplazo de Target.
3. `app_animations.dart`: borrar la clase `AppTransitions` entera (líneas 14–93 en b84e65aa). NO borrar nada más del archivo (la extensión `AppAnimationsExtension`, `FadeIndexedStack`, `CelebrationOverlay`, etc. se quedan).
4. Verificar imports: en `main_screen.dart` y `home_friends_view.dart`, si `app_animations.dart` ya no se usa para nada más en ese archivo, quitar el import; si se usa (p.ej. `FadeIndexedStack` en `main_screen.dart` — SÍ se usa), dejarlo. `material.dart` ya provee `MaterialPageRoute`.
5. Confirmar que no quedan referencias: `grep -rn "AppTransitions" flutter_client/lib` debe devolver 0 resultados.
6. `dart format` sobre los archivos tocados.

## Boundaries

- NO tocar el resto de `app_animations.dart`.
- NO tocar `app_page_transitions.dart`.
- NO cambiar lógica de navegación (el `await` de `home_friends_view` se conserva; el callback `onLogout` se conserva).
- Si los excerpts no coinciden (drift desde b84e65aa), PARAR y reportar.

## Verification

- **Mecánica**: `grep -rn "AppTransitions" flutter_client/lib` ⇒ vacío. `cd flutter_client && flutter analyze` (~4 min) — cero issues nuevos.
- **Feel check**: correr la app en Android (o desktop) y confirmar:
  - Abrir Ajustes desde Home y Notificaciones desde la campana: ambas entran con el fade+drift brandeado, igual que cualquier otra pantalla.
  - El botón atrás cierra ambas con la salida rápida (el pop no arranca lento como antes).
  - Desde el home de amigos, volver de Notificaciones sigue refrescando el contador de no leídas (el `await` sigue funcionando).
- **Done when**: 0 referencias a `AppTransitions`, las 3 rutas usan la transición global, analyze limpio.
