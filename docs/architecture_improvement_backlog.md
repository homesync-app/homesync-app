# HomeSync - Backlog de mejoras tecnicas

Documento vivo para ordenar mejoras posteriores al upgrade de dependencias y Riverpod 3.
La idea no es hacer todo junto, sino elegir cortes chicos, testeables y con impacto claro antes del lanzamiento.

## Filosofia guia: vibe coding first

Toda mejora se evalua con un solo criterio: **le hace la vida mas facil o mas dificil a la IA cuando vuelva a tocar este codigo?**

Principios:

- **Documentacion escrita = infraestructura.** Un archivo `.md` con el contrato de un RPC vale mas que un refactor.
- **Contratos explicitos > convenciones implicitas.** Si una regla no esta escrita en un archivo, no existe.
- **Predecible > elegante.** Cuatro implementaciones copy-paste son mejores que una abstraccion generica que obliga a saltar entre archivos.
- **Nombres estables y versionados** para acciones criticas (`complete_task_v1`).
- **Un solo lugar para cambiar una cosa.** Si modificar un comportamiento requiere tocar 5 archivos, es deuda.
- **Evitar abstracciones nuevas** salvo que resuelvan un dolor concreto y repetido.

Bandera roja: cualquier propuesta que agregue una capa, un concepto nuevo o un tipo generico parametrizado tiene que justificar por que la IA va a estar **mejor** despues, no solo por que el codigo va a estar "mas limpio".

## 1. Comandos transaccionales versionados (prioridad maxima)

Objetivo: cada accion critica tiene un RPC versionado, transaccional e idempotente, con contrato escrito.

Por que es lo mas vibe-friendly del backlog:

- La IA no infiere que tablas se tocan: las ve en el RPC.
- El payload de respuesta es suficiente para refrescar la UI sin adivinanzas.
- El nombre versionado (`_v1`) garantiza que la app no rompe si despues sale `_v2`.
- Centraliza side effects: un solo lugar para auditar.

Ejemplos objetivo:

- `delete_expense_v1`
- `save_expense_v1` (o documentar el actual `save_expense_v4` como comando principal)
- `complete_task_v1`
- `complete_tasks_batch_v1`
- `undo_task_completion_v1`
- `approve_task_v1`
- `reject_task_v1`
- `settle_debt_v1`
- `create_shopping_request_v1`
- `approve_shopping_request_v1`

Reglas obligatorias por comando:

- Valida permisos con `current_app_user_id()`.
- Actualiza todas las tablas afectadas en una unica transaccion.
- Devuelve payload suficiente para refrescar UI sin inferencias.
- Idempotencia clara: repetir request no duplica monedas, gastos, actividades ni notificaciones.
- Nombre y version estables.
- **Cada comando tiene una entrada en `docs/rpc_contracts.md`** (ver seccion 2).

Primeros candidatos:

1. `delete_expense_v1`: borrar gasto + splits + feed/balance coherente.
2. `complete_task_v1`: completar tarea + XP/coins + actividad + recurrencia.
3. `approve_task_v1`: aprobar pendiente + recompensas + actividad.
4. `undo_task_completion_v1`: revertir tarea + recompensas + actividad.

## 2. Documentacion como infraestructura (nuevo)

Tres archivos vivos que la IA debe poder leer al principio de cualquier tarea.

### 2.1 `docs/rpc_contracts.md`

Una entrada por cada RPC con:

- Nombre y version.
- Inputs (con tipos).
- Outputs (estructura del payload).
- Tablas que toca (lectura/escritura).
- Errores posibles (codigo + significado).
- **Providers a invalidar en el cliente despues de exito.**
- Idempotencia: si/no, en base a que key.

### 2.2 `docs/db_schema.md`

Snapshot del schema actual, idealmente autogenerado desde Supabase. La IA hoy adivina nombres de columnas; esto lo arregla.

### 2.3 `docs/antipatterns.md`

Lista de "no hacer" especificos del repo. Ejemplos:

- "No invalides `householdProvider` desde acciones de tareas; causa rebuild en cascada."
- "No mezcles `FeedItemKind.activity` con `FeedItemKind.resource` en la misma card."
- "No metas side effects en widgets que pueden quedar pausados por `TickerMode`."

Vale mas que diez refactors: evita que la IA repita errores que ya cometio.

## 3. Contrato del feed combinado

Problema actual:

- "Movimientos del hogar" mezcla recursos reales (gastos/ingresos/settlements/planned) y actividades sociales/tareas segun origen.
- Las cards deciden accion por inferencias de strings.

Reglas a definir (escritas en `docs/feed_contract.md`):

- Que tipos aparecen en "Movimientos del hogar".
- Que tipos son recursos reales persistentes.
- Que tipos son actividades derivadas.
- Que pasa al borrar/deshacer/aprobar: se elimina el recurso, se oculta la actividad o se agrega una compensatoria.
- Que fuente manda si hay conflicto: tabla de recursos vs `household_activities`.

Modelo:

- `FeedItemKind.resource`: gasto, ingreso, settlement, planned expense.
- `FeedItemKind.activity`: tarea completada, aprobacion, nota, recompensa.
- `FeedItemKind.system`: eventos generados por reglas internas.

Primer corte:

- Documentar contrato de `get_combined_feed` en `docs/rpc_contracts.md`.
- Ajustar `FeedItemModel` para distinguir tipo visual de tipo de recurso.
- Cada card decide accion por `kind`, no por strings.

## 4. Politica unica de optimistic updates (escrita)

Crear `docs/optimistic_policy.md` con una tabla por accion:

| action | optimistic_behavior | rollback | invalidations | offline_behavior |
|--------|--------------------|----|---------------|------------------|

Politica base:

- **Alto impacto financiero** (gastos, settlements): optimismo limitado. Loading, esperar backend, refrescar.
- **Tareas/shopping reversibles**: optimistic update con rollback.
- **Feed combinado**: backend es fuente de verdad. Solo permitir remocion local inmediata y luego invalidar.
- **Offline queue**: mostrar estado "en cola" cuando el resultado no esta confirmado.

Si la politica no esta escrita, no existe. Convenciones implicitas = la IA improvisa = bugs.

## 5. Convencion de nombres de providers (nuevo)

Hoy hay mezcla. Regla escrita en `docs/conventions.md`:

- `xxxProvider` -> lectura/derivacion (sin mutaciones).
- `xxxControllerProvider` -> mutaciones / acciones (AsyncNotifier).
- `xxxStreamProvider` -> realtime/sockets.
- `xxx<Action>Provider` -> calculos derivados especificos.

Beneficio vibe: la IA no inventa nombres nuevos ni duplica providers.

## 6. Tests como especificacion ejecutable

Tests de providers/notifiers, no solo de modelos/use cases. **El valor para la IA es que los nombres de los tests son la especificacion.**

Reglas de naming:

- "completar tarea diaria invalida feed/balance/stats"
- "borrar gasto remueve localmente y revierte si falla"
- "aprobar tarea acredita XP/coins y mueve a completada"

Flows prioritarios (en este orden):

1. Borrar gasto: remueve gasto localmente, invalida balances/feed/resumen, revierte si falla.
2. Completar tarea diaria: actualiza/remueve segun regla, invalida actividad/balance/stats, recurrencia sin duplicar.
3. Aprobar tarea: mueve pendiente a completada, acredita XP/coins, refresca feed/stats.
4. Crear movimiento: crea gasto/ingreso, respeta split/privacy, actualiza resumen/balances/feed.
5. Deshacer tarea completada: revierte actividad/recompensas, vuelve a pendientes, refresca todo.

Patron:

- Repos fake controlables.
- `ProviderContainer.test()`.
- Verificar `AsyncValue`, invalidaciones esperadas y rollback.

## 7. Riverpod 3 - reglas escritas, no auditoria libre

"Auditar keepAlive" es el tipo de tarea que la IA hace mal porque necesita contexto runtime. Convertirlo en **regla** en `docs/conventions.md`:

- Providers con realtime/sockets: `@Riverpod(keepAlive: true)`.
- Resto: `autoDispose` por defecto.
- Retry declarativo solo en providers de lectura. Nunca en errores de negocio/auth/permisos/validacion.
- `ref.mounted` obligatorio en callbacks async/fire-and-forget.
- Nada de side effects criticos en widgets pausables por `TickerMode`.

**Descartado por ahora**: migracion a `Mutation`. AsyncNotifier ya funciona y la IA lo conoce. No agregamos un concepto nuevo sin un dolor concreto.

## 8. Cosas que NO vamos a hacer (o postergamos)

### 8.1 `PageState<T>` generico (descartado)

Bandera roja vibe-coding: tipo generico parametrizado que obliga a la IA a saltar entre archivos para entender `loadMore`. Cuatro implementaciones copy-paste (`NotificationsController`, `PaginatedSavingsGoals`, `PaginatedRewards`, `Tasks.loadMore`) son **mas faciles de modificar** que una abstraccion compartida.

Solo se revisa si aparece un bug repetido entre las cuatro.

### 8.2 Refactor masivo de widgets enormes (postergado)

Un archivo de 1500 lineas con todo junto es a veces **mas** vibe-friendly que 8 archivitos con estado disperso. El criterio no es "tamaño" sino:

> Puedo cambiar el comportamiento X tocando un solo lugar?

Solo extraer cuando hay **logica reutilizada en otra pantalla**. No por estetica.

Archivos a vigilar (no a refactorizar de oficio):

- `setup_screen.dart`
- `expenses_screen.dart`
- `expense_form_sheet.dart`
- `home_family_view.dart`

### 8.3 Migracion a `Mutation` (postergado)

Concepto nuevo sin dolor concreto. AsyncNotifier sigue.

### 8.4 `flutter_lints 6` como item de backlog (sacado)

No es accionable. Los lints aparecen en `flutter analyze` y se arreglan en el corte del momento.

## 9. Beneficios del upgrade de tooling/dependencias (referencia)

### build_runner/source_gen

- Menos friccion con analyzer nuevo.
- Generacion Riverpod alineada a Dart/Flutter actuales.
- Menos riesgo de quedar clavados en tooling viejo.

### Firebase/Supabase

- Parches de compatibilidad.
- Mejor soporte de plataformas recientes.
- Menos riesgo con auth/messaging/crashlytics.

### package_info/device_info/share_plus

- Menos warnings/build issues en plataformas nuevas.
- Mejor soporte para APIs actuales de Android.

## 10. Orden de trabajo

1. **Comandos transaccionales `_v1`** (#1) - maximo retorno vibe.
2. **`docs/rpc_contracts.md` + `docs/db_schema.md`** (#2) - documentar lo que ya existe mientras se crean los comandos.
3. **Contrato del feed combinado** (#3).
4. **`docs/optimistic_policy.md` escrita** (#4).
5. **`docs/conventions.md` + `docs/antipatterns.md`** (#5, #7).
6. **Tests como spec ejecutable** (#6).
7. Resto, segun aparezca dolor real.

## 11. Criterio de aceptacion general

Cada mejora cierra con:

- `flutter analyze` limpio.
- Tests relevantes con nombres descriptivos (son la spec).
- Si toca SQL/RPC/RLS: smoke tests manuales de los flujos criticos indicados en `AGENTS.md`.
- **Entrada en `docs/rpc_contracts.md`** si toca RPCs.
- Resumen de providers invalidados/actualizados en el commit/PR.
- Nota de rollback si afecta datos productivos.
