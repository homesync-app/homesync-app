# Planes de mejora de animaciones — HomeSync

Generados por el skill `improve-animations` (audit del 2026-07-11, commit `b84e65aa`).
Cada plan es autocontenido: cualquier agente puede ejecutarlo sin contexto de la conversación.
Para ejecutar uno: `improve-animations execute plans/NNN-....md` (o dárselo a cualquier agente).

| # | Plan | Severidad | Categoría | Status |
| --- | --- | --- | --- | --- |
| 001 | [Pop-in crisp en detalle de gasto](001-expense-detail-pop-in.md) | HIGH | Easing & duration | DONE |
| 002 | [Gate de reduced-motion global](002-reduced-motion-gate.md) | MEDIUM | Accessibility | DONE |
| 003 | [Entradas sobre tokens AppMotion](003-entrance-motion-tokens.md) | MEDIUM | Cohesion & tokens | DONE |
| 004 | [Retirar AppTransitions legacy](004-retire-apptransitions.md) | LOW | Cohesion | DONE |
| 005 | [Aligerar cambio de tab](005-tab-switch-budget.md) | LOW | Purpose & frequency | DONE |

## Orden de ejecución recomendado

1. **001** — el HIGH; además crea `animatePopIn`, que 003 necesita.
2. **005** — toca `app_animations.dart` (región `FadeIndexedStack`), independiente de 001.
3. **004** — toca `app_animations.dart` (borra `AppTransitions`), independiente.
4. **003** — retokeniza los helpers; DEPENDE de 001 (edita `animatePopIn`) y conviene tras 005/004 para no pisar diffs en el mismo archivo.
5. **002** — el más ancho (~8 archivos), sin dependencias; puede ir en cualquier momento, pero al final evita conflictos.

## Dependencias

- 003 → requiere 001 aplicado (si `animatePopIn` no existe, 003 debe abortar).
- 001, 003, 004 y 005 editan `app_animations.dart` en regiones distintas — ejecutarlos en serie, no en paralelo.
- 002 es independiente de todos.

## Notas de verificación comunes

- `flutter analyze` tarda ~4 min en este repo; correrlo una vez por plan (o una vez al final de una tanda).
- El feel-check de 002 requiere un dispositivo/emulador con el setting de accesibilidad "Quitar animaciones".
- Regresión conocida a vigilar en 005: foco del teclado en Compras (ver plan).

## Fuera de alcance (deliberado, no reabrir)

- Draw-ins de 700–900ms en charts/progress rings (explicativos, exentos del presupuesto de UI).
- `AnimatedAmount` count-up de 700ms (coreografía premium deliberada).
- `elasticOut` en `weekly_winner_screen` (celebración: ahí corresponde).
- Vendor (`shared/widgets/vendor/**`) y Portal Labs (`shared/widgets/portal_labs/**`).

## Oportunidades detectadas pero sin plan (pedir si se quieren)

- Salida/entrada animada de filas en listas (no hay ningún `AnimatedList` en `lib/`): completar tarea o tildar ítem de compras teletransporta la fila entre secciones.
- El pulso "te toca" del avatar (`user_avatar.dart:347`) podría latir 3–4 ciclos y asentarse, en vez de latir para siempre.
