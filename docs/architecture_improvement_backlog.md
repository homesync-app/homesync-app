# HomeSync - Backlog de mejoras tecnicas

Documento vivo para ordenar mejoras posteriores al upgrade de dependencias y Riverpod 3.
La idea no es hacer todo junto, sino elegir cortes chicos, testeables y con impacto claro antes del lanzamiento.

## Estado actual del backlog

Ultima actualizacion: 2026-07-19 (ver seccion 13 para la sesion de produccion mas reciente).

- Hecho: `delete_expense_v1`, `complete_task_v1`, `approve_task_v1`, `reject_task_v1`, `undo_task_completion_v1`.
- Hecho: `settle_debt_v1` (idempotente por `p_request_id`, titulo UTF-8 corregido, smoke-gateado, contrato en `docs/rpc_contracts.md`).
- Hecho: `docs/rpc_contracts.md`, `docs/db_schema.md`, `docs/optimistic_policy.md`, `docs/conventions.md`, `docs/antipatterns.md`, `docs/feed_contract.md`.
- Parcial: `get_combined_feed` tiene contrato funcional y contrato de RPC, pero falta `FeedItemKind` en el modelo.
- Parcial: `save_expense_v4` queda como canonico actual, pero falta contrato completo en `docs/rpc_contracts.md`.
- Pendiente: `complete_tasks_batch_v1`, `create_shopping_request_v1`, `approve_shopping_request_v1`.
- Pendiente: tests de providers/notifiers como especificacion ejecutable para delete expense, complete task, approve task y undo task.

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

- Hecho: documentar contrato de `get_combined_feed` en `docs/rpc_contracts.md`.
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

## 12. Sesion de mantenimiento 2026-06-30 (hecho + pendiente)

Sesion de upgrade de stack + limpieza, verificada con el MCP de Dart (`dart mcp-server`,
analisis en segundos). Todo lo "hecho" quedo en verde por MCP (`No errors`).

### Hecho (verificado)

- **Dependencias**: 57 paquetes actualizados dentro de sus rangos (supabase_flutter 2.12->2.15,
  riverpod 3.2->3.3.2, firebase, purchases_flutter, video_player, etc.) + `.g.dart` regenerados.
  Floors de `pubspec.yaml` alineados.
- **MCP de Dart configurado** en `.kiro/settings/mcp.json` (server `dart`). Da loop de
  analisis rapido (`analyze_files`) sin el cold-start lento del CLI + plugin riverpod_lint.
- **Edge Functions -> `Deno.serve`**: migradas las 9 que usaban el `serve` deprecado de
  `std@0.168.0/http/server.ts` (scan-receipt + send-notification, send-feedback-reply,
  send-feedback-ack, revenuecat-webhook, mercadopago-api, generate-custom-avatar,
  delete-custom-avatar, cleanup-old-receipts). Deployadas a prod + smoke-tested (OPTIONS 200,
  webhooks sin auth 401, ningun 500 de arranque). Solo cambia el bootstrap HTTP, cero cambio
  de comportamiento.
- **debugPrint de debug** gateados con `if (kDebugMode)` en `premium_animated_avatar.dart`
  (no se eliminan en release por default). Requirio `import 'package:flutter/foundation.dart'`
  (no viene por material.dart; lo atrapo el analyzer).
- **`savings_model.dart`**: casts no-null fragiles endurecidos (`as num?` con default) para no
  crashear si Supabase devuelve null.
- **keepAlive (fix de raiz)**: `supabaseClientProvider` -> `@Riverpod(keepAlive: true)` (es el
  singleton global de Supabase, no tiene estado descartable). Limpio ~10 warnings
  `only_use_keep_alive_inside_keep_alive` de los repos que lo observaban. Ademas los 7 use-cases
  de `stats_provider` -> keepAlive (cadena Controller->use-case->repo->client toda keepAlive).
- **Mojibake (double-encoded UTF-8)**: arreglado con `ftfy` solo en archivos con mojibake
  ACCIDENTAL (28 lineas en 4 archivos). Incluia bugs visibles al usuario: emoji `label` (etiqueta)
  corrupto en `expense_shopping_components.dart` (4 sitios) y un emoji en
  `settings_admin_components.dart`, mas un separador en string de UI en `expense_form_sheet.dart`.
  El resto eran comentarios. NO se tocaron los mapas con mojibake INTENCIONAL (data-repair):
  `user_avatar.dart` (aliases legados de avatares), `shopping_localization.dart` (normalizacion
  de acentos), `activity_presentation.dart` (reparacion deliberada).
- **God files extraidos** (a part files `*_widgets.dart` / `*_builders.dart`, misma libreria,
  comparten imports). NOTA: esto va en tension con la seccion 8.2 de este backlog (postergar
  refactor de widgets grandes); se hizo por pedido explicito del owner, y son moves puros
  (sin cambio de logica), verificados en verde:
  - `expense_form_sheet.dart`: 1760 -> 1324 (13 builders, varios con tecnica setState->handler).
  - `savings_tab.dart`: 2109 -> 531 (9 clases widget a `savings_tab_widgets.dart`).
  - `tasks_screen.dart`: 1844 -> 957 (`_TaskCard`/State + `_SectionHeader`/`_TodayDoneCelebration`
    a `tasks_screen_widgets.dart`).

### Pendiente (documentado, NO hacer a ciegas)

- **`avoid_public_notifier_properties` en `task_provider.dart:105`** (`Tasks.hasMore` getter
  publico, lo usa la UI en `tasks_screen.dart` para "cargar mas"). Fix correcto per Riverpod 3:
  exponer `hasMore` DENTRO del `state` (mirror de `RewardsPageState`/`SavingsGoalsPageState`/
  `NotificationsState` que ya existen). PERO cambia la forma del `state` de `Tasks`
  (`Future<List<TaskModel>>` -> un `TasksPageState`) y toca todos los consumidores de
  `tasksProvider` -> refactor dedicado con testing de paginacion/completar. Coherente con 8.1:
  no abstraer en generico; si se hace, replicar el patron por-feature existente.
- **~27 warnings `only_use_keep_alive_inside_keep_alive` restantes** (task_provider, shopping_provider):
  controllers keepAlive observando use-cases autoDispose. Decision arquitectonica (ver seccion 7):
  marcar keepAlive las cadenas (como se hizo en stats) o repensar que controllers son keepAlive.
  Es codigo deliberado/documentado en varios casos (ej. `expenseRepository` keepAlive evita
  "Cannot use Ref after disposed" en settleDebt).
- **`anonKey` deprecado** (`main.dart:183`) -> `publishableKey`. Requiere generar key
  `sb_publishable_...` en el dashboard de Supabase + actualizar `AppEnvironment`. Las anon keys
  legadas funcionan hasta fin de 2026.
- **`strict-casts: false`** en `analysis_options.yaml`. Activarlo endurece type-safety (los modelos
  hacen `id: json['id']` dynamic->String), pero el analysis server no recarga la opcion `language`
  sin restart, asi que no se pudo medir la cascada de errores en esta sesion. Tarea dedicada.
- **Mojibake en COMENTARIOS no-criticos**: el comentario huerfano sobre `_closeSheet` en
  `expense_form_sheet.dart` ya se limpio via ftfy. Si aparece mas mojibake accidental, el patron
  es: `python -c "import ftfy; ..."` solo sobre archivos SIN mojibake intencional.
- **`setup_screen.dart` (2333 lineas)**: NO candidato a move mecanico (la navegacion del wizard
  con `setState(() => _currentStep = X)` esta entretejida en casi todos los step builders). El fix
  correcto es un `SetupWizardController` (Notifier que sea dueno de `_currentStep` + navegacion),
  refactor deliberado con tests. Otros god files monoliticos: `expenses_screen.dart` (~1959),
  `couple_rewards_screen.dart` (~1828), `admin_workspace_screen.dart` (~1704).

## 13. Sesion de produccion 2026-07-19 (hecho + pendiente supervisado)

Sesion de cierre pre-produccion con verificacion por SQL contra prod (MCP de Supabase).

### Hecho (verificado)

- **Backup**: `develop` pusheado a `origin/develop` (venia 59 commits adelante) + commit
  del trabajo OCR pendiente (matcher deterministico, parser con tests, OcrInsights admin).
- **DB / indices**: migracion `20260719120000_fk_covering_indexes` — 34 FKs sin indice
  cubiertas (advisor `unindexed_foreign_keys`: 34 -> 0). Los indices "unused" NO se
  borraron a proposito: varios son de features recien lanzadas (dedup OCR, pools,
  plan_tier) y el advisor no tiene trafico suficiente para ser evidencia.
- **DB / RLS**: migraciones `20260719120500` + `20260719121500` — politicas SELECT
  permissive duplicadas consolidadas en 15 tablas (OR literal de las quals, scope
  `TO authenticated`). Advisor `multiple_permissive_policies`: 26 -> 1 (queda el UPDATE
  de `household_members`, ver pendientes). Verificado con snapshots por rol
  (usuario real / admin / anon) byte-identicos antes y despues.
- **RPC duelo semanal**: `save_weekly_duel_result` endurecido en el lugar
  (`20260719123000`): membresia obligatoria, semana ISO acotada, ganador/perdedor/XP
  recalculados del ledger. El payload del cliente ya no se persiste. Contrato agregado
  a `docs/rpc_contracts.md`. Antes cualquier authenticated podia escribir el historial
  de cualquier hogar.
- **flutter analyze**: limpio (0 issues). Los warnings de riverpod_lint (hasMore,
  keepAlive) NO salen en `flutter analyze`; se miden con `dart run custom_lint`.

### Pendiente que requiere decision/supervision del owner

- **`application_logs` legible por cualquier authenticated** (`qual=true`, ~101k filas).
  Decidir si debe ser solo-admin. Cambiarlo altera comportamiento: primero confirmar
  que la app nunca lee esta tabla desde el cliente (grep `application_logs` en
  `flutter_client/lib`); si solo la lee el panel admin, restringir a
  `is_current_app_admin()`.
- **`household_members` UPDATE con 2 politicas permissive**: el unico overlap restante.
  El OR-merge de UPDATE requiere mergear `USING` y `WITH CHECK` por separado; hacerlo
  con smoke desde la app (editar rol de un miembro como adulto y como no-admin).
- **Leaked password protection** (Auth -> Settings en el dashboard de Supabase): 1 click
  del owner. Tambien mover la extension `pg_net` fuera de `public` cuando haya ventana.
- **Cuentas QA en prod**: `admin@homesync.qa` (`5ac9da1b-...`) existe en prod con
  `is_admin=true` y las contrasenias QA viajan como constantes en el binario
  (`admin_testing_config.dart`). El gate `enableAdminTesting` exige `!isProduction`,
  asi que no es backdoor, pero conviene rotar esas credenciales y/o deshabilitar las
  cuentas QA en Firebase prod.
- **CI de Flutter apagada**: `flutter_ci.yml.disabled`. Reactivar cuando el tiempo de
  build sea aceptable; hoy solo corren `tests.yml` y `edge_functions.yml`.
- **Auditoria SECURITY DEFINER**: 124 funciones ejecutables por authenticated (patron
  de diseno). Auditar por lotes que todas validen `current_app_user_id()`; el caso
  `save_weekly_duel_result` demostro que puede haber huecos.
- **Drenaje l10n**: 322 strings en `test/hardcoded_spanish_baseline.txt` + 102 en el
  baseline de encoding. Cortes de 20-30 strings por sesion.
- **`strict-casts: true`**: tarea dedicada (cascada de errores en modelos, requiere
  restart del analysis server para medir).
