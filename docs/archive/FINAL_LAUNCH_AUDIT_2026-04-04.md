# HomeSync - Final Launch Audit

Generado: 2026-04-04
Ultima actualizacion: 2026-04-04 (post-Fase 1/2/3 tasks_enabled)
Workspace: `C:\Users\Blas_\Documents\Aplicacion de Pareja`

## Resumen ejecutivo

Estado general: todavia no esta listo para publicar una release final hoy, pero el frente tecnico principal ya no esta bloqueado.

Estado confirmado hoy:
- El build Android `release` ya compila localmente.
- La suite de tests esta verde en la validacion actual.
- El runtime ya no depende de defaults reales embebidos en `app_environment.dart`.
- El flujo local/CI ya usa archivos de entorno y `dart-define`.
- La primera pasada fuerte de observabilidad (`catch (e, stack)`) ya fue hecha en providers y services.
- Falta smoke test real del build release en dispositivo.
- Faltan screenshots y formularios obligatorios de Play Store.

## 1. Bloqueantes y riesgos reales

### 1.1 Release Android: compila, pero falta smoke test

Confirmado:
- Existe artefacto release en `flutter_client/build/app/outputs/bundle/release/app-release.aab`.
- `flutter_client/android/app/build.gradle.kts` ya incluye el saneamiento del `GeneratedPluginRegistrant.java` para release.

Estado:
- El bloqueo original de compilacion ya no existe.
- El riesgo actual es runtime release con R8/minify, no build failure.

Pendiente:
- Instalar y recorrer un build release real en dispositivo.
- Validar al menos login, carga inicial, dashboard, tareas, gastos, rewards y notificaciones.
- Nota operativa: hoy no se pudo instalar el APK release sobre el debug existente en el telefono de prueba por `INSTALL_FAILED_UPDATE_INCOMPATIBLE` (firma distinta). Para el smoke test real hay que desinstalar la variante actual o usar un dispositivo limpio.

### 1.2 R8 / ProGuard: ya configurado, falta validacion final

Confirmado:
- `flutter_client/android/app/build.gradle.kts` tiene:
  - `isMinifyEnabled = true`
  - `isShrinkResources = true`
- Existe `flutter_client/android/app/proguard-rules.pro`.
- Las reglas actuales cubren Flutter, Firebase, Google Sign-In, Supabase, OkHttp, IAP y tipos basicos de serializacion.

Estado:
- El problema ya no es "falta el archivo".
- El punto pendiente es validar que las reglas actuales alcanzan en runtime release.

Conclusion:
- Sigue siendo un riesgo tecnico de publicacion.
- Ya no es un bloqueante de build.

### 1.3 Tests: hoy estan verdes

Confirmado:
- `flutter analyze --no-fatal-infos --no-fatal-warnings`: verde.
- `flutter test`: verde en la ultima corrida completa.
- Tambien pasaron pruebas focalizadas sobre login, tasks, connectivity y providers.
- Se agregaron tests para `main_navigation` y `feature_gap_regression`.

Estado:
- Este bloqueante tecnico ya no sigue abierto.
- Conviene volver a correrlos despues de cambios grandes, pero no frena el lanzamiento tecnico.

### 1.4 Play Store: faltan assets y formularios

Confirmado:
- No hay screenshots finales listos en el repo para subir a Play Console.
- La ficha de store sigue necesitando revision final contra la version actual.

Pendiente:
- Generar screenshots reales.
- Completar Content Rating.
- Completar Target Audience.
- Completar Data Safety.
- Revisar descripcion corta/larga y metadata final.

Conclusion:
- Este es uno de los bloqueantes reales que quedan para publicacion.

### 1.5 CI de produccion: mas sano, pero faltan secrets definitivos

Confirmado:
- `.github/workflows/deploy-production.yml` ya builda con `APP_ENV=production`.
- El workflow ya genera `.env.production` para el build.

Estado:
- El problema original de compilar "production" en `staging" ya fue corregido.
- Queda como tarea operativa consolidar los secrets definitivos del pipeline.

### 1.6 Configuracion sensible en runtime: corregido

Confirmado:
- `flutter_client/lib/config/app_environment.dart` ya no expone defaults reales.
- La app falla temprano cuando faltan `dart-define` obligatorios.
- El flujo local se apoya en `.env.local`.
- El flujo de release/CI se apoya en `.env.production`.

Estado:
- La deuda fuerte de tener configuracion real embebida en runtime ya fue resuelta.
- Sigue siendo importante manejar bien los archivos `.env` y los secrets externos.

### 1.7 Edge Functions: mejor defensa, falta validar deploy

Confirmado en repo:
- `supabase/functions/send-notification/index.ts`
- `supabase/functions/mercadopago-api/index.ts`

Estado actual:
- Ambas usan `SUPABASE_SERVICE_ROLE_KEY`.
- Ya se agrego validacion defensiva de bearer token para llamadas directas desde la app.
- `send-notification` ahora exige JWT cuando no viene como webhook.
- `mercadopago-api` ahora exige JWT para acciones POST de app, manteniendo webhook y callback OAuth abiertos.

Pendiente:
- Verificar configuracion de deploy y `verify_jwt` en Supabase para cada function.

### 1.8 Dark mode: deuda real

Confirmado por busqueda previa:
- `Colors.white`: muchas ocurrencias repartidas.
- `Colors.black`: muchas ocurrencias repartidas.

Conclusion:
- No bloquea publicar si todo lo demas esta sano.
- Pero es una deuda UX visible y real.

### 1.9 Observabilidad: gran avance, no cerrada al 100%

Confirmado por busqueda actual:
- Bajo de ~110 a **60 ocurrencias** de `catch (e) {` en `lib/`.
- Los remanentes estan concentrados en UI, pantallas y algunos repositorios puntuales.

Trabajo ya hecho:
- Primera pasada fuerte sobre providers y services criticos.
- Se actualizaron, entre otros:
  - `task_provider`
  - `shopping_provider`
  - `expense_provider`
  - `reward_provider`
  - `savings_provider`
  - `connectivity_provider`
  - `firebase_auth_service`
  - `supabase_auth_service`
  - `logger_service`
  - `notification_service`
  - `repository_error_handler`
  - `retry_service`
  - `admin_rpc_service`
  - `stats_rpc_service`
  - `premium_service`
  - `sync_service`

Estado actual:
- Los `catch (e)` remanentes quedaron concentrados mucho mas en UI, pantallas y algunos repositorios puntuales.
- La mejora de observabilidad en produccion ya es material.

## 2. Mejoras de arquitectura aplicadas (nueva seccion)

### 2.1 Connectivity Provider: de no-op a funcional

Antes:
- `connectivity_provider.dart` siempre devolvia `isOnline: true`.
- Todo el sistema de cola offline nunca se activaba.

Ahora:
- `_applyConnectivityResult()` procesa resultados reales de `ConnectivityResult`.
- `_checkConnection()` se ejecuta en `_init()` al arrancar.
- El listener de `onConnectivityChanged` actualiza el estado en tiempo real.

Archivos:
- `flutter_client/lib/core/providers/connectivity_provider.dart`

### 2.2 mcp_server: eliminado

Antes:
- `mcp_server: any` en `pubspec.yaml` sin version fija.
- No se usaba en ningun archivo de `lib/`.

Ahora:
- Dependencia comentada/eliminada de `pubspec.yaml`.

Archivos:
- `flutter_client/pubspec.yaml`

### 2.3 Either -> throw Exception: corregido en providers principales

Antes:
- `task_provider`, `expense_provider`, `shopping_provider`, `savings_provider` hacian `throw Exception(failure.message)`, destruyendo el tipado seguro de `Either<Failure, T>`.

Ahora:
- Todos los providers principales propagan `throw failure` (el `Failure` tipado).
- La UI recibe `AsyncError` con el tipo correcto, no un `Exception` generico.

Archivos:
- `flutter_client/lib/features/tasks/presentation/providers/task_provider.dart`
- `flutter_client/lib/features/expenses/presentation/providers/expense_provider.dart`
- `flutter_client/lib/features/shopping/presentation/providers/shopping_provider.dart`
- `flutter_client/lib/features/savings/presentation/providers/savings_provider.dart`

### 2.4 core_providers.dart: de 552 lineas a barrel de 7 lineas

Antes:
- `core_providers.dart` tenia 552 lineas mezclando providers manuales con code-gen.

Ahora:
- Es un barrel de 7 lineas con exports de modulos separados:
  - `admin_providers.dart`
  - `app_ui_providers.dart`
  - `auth_session_providers.dart`
  - `identity_providers.dart`
  - `mercadopago_providers.dart`
  - `qa_session_providers.dart`
  - `service_providers.dart`

Archivos:
- `flutter_client/lib/core/providers/core_providers.dart`

### 2.5 N+1 en QA admin: resuelto con RPC batch

Antes:
- `supabase_task_repository.dart` hacia N llamadas RPC en loop para completar tareas en modo QA.

Ahora:
- Usa la RPC `qa_admin_complete_tasks_batch` que procesa todo en una sola llamada.
- Migracion aplicada: `20260402170000_admin_qa_complete_tasks_batch.sql`.

Archivos:
- `flutter_client/lib/features/tasks/data/repositories/supabase_task_repository.dart`

### 2.6 Navegacion dinamica: sin setIndex hardcodeados

Antes:
- 13 referencias a `setIndex(1)`, `setIndex(2)`, `setIndex(5)` hardcodeados en toda la app.
- Si una tab desaparecia, los indices se desalineaban y la navegacion se rompia.

Ahora:
- Helper `main_navigation.dart` con enum `MainTab` y funciones `visibleMainTabs()` / `indexForMainTab()`.
- `main_screen.dart` construye tabs dinamicamente desde `visibleMainTabs(caps)`.
- Todos los `setIndex` hardcodeados reemplazados por resolucion dinamica.
- Test unitario `main_navigation_test.dart` cubriendo 3 escenarios.

Archivos:
- `flutter_client/lib/features/dashboard/presentation/main_navigation.dart` (nuevo)
- `flutter_client/lib/features/dashboard/presentation/screens/main_screen.dart`
- `flutter_client/test/main_navigation_test.dart` (nuevo)
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_solo_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_couple_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_family_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_friends_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/household_social_hub_screen.dart`

### 2.7 Modo "Finanzas + Compras": tareas habilitables por hogar

Antes:
- Tareas era una feature obligatoria, sin forma de desactivarla.

Ahora (3 fases completas):
- **Fase 1**: Migracion `tasks_enabled BOOLEAN NOT NULL DEFAULT true` en `households`. `HouseholdModel` y `HouseholdCapabilities` con `showTasks`/`showStats`. Navegacion dinamica.
- **Fase 2**: Home y FAB sin tareas cuando `tasks_enabled = false`. Secciones de tareas ocultas en todas las `home_*_view.dart`.
- **Fase 3**: Toggle en Settings para activar/desactivar. `setup_screen.dart` saltea templates de tareas si el hogar tiene tareas desactivadas. Persistencia via `updateTasksEnabled()` en repository.

Archivos:
- `supabase/migrations/20260404000000_add_tasks_enabled_to_households.sql`
- `flutter_client/lib/features/household/domain/models/household_model.dart`
- `flutter_client/lib/features/household/domain/models/household_capabilities.dart`
- `flutter_client/lib/features/household/presentation/providers/household_providers.dart`
- `flutter_client/lib/features/household/domain/repositories/household_repository.dart`
- `flutter_client/lib/features/household/data/repositories/supabase_household_repository.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/home_screen.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_solo_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_couple_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_family_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_friends_view.dart`
- `flutter_client/lib/features/household/presentation/screens/setup_screen.dart`
- `flutter_client/lib/features/settings/presentation/screens/settings_screen.dart`
- `flutter_client/lib/features/settings/presentation/widgets/settings_household_components.dart`

### 2.8 Clean Architecture: mayormente completada

Estado actual:
- ✅ stats: 9 use cases
- ✅ household: 5 use cases
- ✅ premium: data/domain + 4 use cases
- ✅ notifications: data/domain + 3 use cases + entity

## 3. Afirmaciones del informe original que habia que corregir

### 3.1 Politica de privacidad

Correccion:
- No partimos de cero.
- Ya existe material base en el repo, aunque sigue faltando URL publica final y asociacion en Play Console.

### 3.2 `AppEmptyState`

Correccion:
- El widget ya existe.
- No hace falta crearlo desde cero.
- Si se trabaja este frente, seria para unificar adopcion, no para inventar la pieza.

### 3.3 RLS "parcial"

Correccion:
- En el estado actual del proyecto, las tablas publicas auditadas relevantes ya tienen RLS habilitado.
- La lectura correcta es: revisar policies finas y consistencia, no asumir ausencia general de RLS.

### 3.4 "El mayor riesgo oculto es R8/minify"

Matiz actualizado:
- Sigue siendo un riesgo importante.
- Pero el mayor bloqueante tecnico inicial ya fue resuelto: el release compila.
- Ahora el foco correcto es smoke test release + Play Store readiness.

## 4. Cosas que no puedo cerrar solo desde el repo

No confirmables solo con codigo:
- Que el build release funcione bien en dispositivo durante un recorrido manual completo.
- Que Crashlytics y dashboards esten bien configurados en consola.
- Que Play Console tenga completos Content Rating, Data Safety y Target Audience.
- Que los secrets finales de GitHub Actions y Supabase esten cargados y correctos.
- Que el modo "Finanzas + Compras" funcione correctamente con `tasks_enabled = false` en dispositivo real.

## 5. Orden de trabajo recomendado desde hoy

### Fase 1 - cerrar release tecnico real

1. Hacer smoke test manual del build release en dispositivo.
2. Confirmar que login, bootstrap inicial, dashboard, tasks, expenses, rewards y notifications no rompen en release.
3. Si aparece un crash de release, ajustar `proguard-rules.pro` o codigo puntual.

### Fase 2 - store readiness

1. Generar screenshots reales.
2. Revisar copy final de la ficha.
3. Completar Content Rating.
4. Completar Target Audience.
5. Completar Data Safety.

### Fase 3 - estabilizacion visual y de DX

1. Segunda pasada chica de `catch (e, stack)` en UI/repositorios (de 60 a menos).
2. Limpieza de mojibake remanente.
3. Migracion progresiva de `Colors.white/black` a theme tokens.

## 6. Recomendacion inmediata

Si seguimos ahora, el mejor siguiente paso es:

1. Generar e instalar un build `release` real.
2. Hacer un smoke test corto y documentar resultado.
3. Si sale bien, pasar directamente a Play Store checklist.
