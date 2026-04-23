# 🏡 HomeSync — Análisis Completo & Plan de Mejoras

**Fecha:** 3 de Marzo de 2026  
**Estado actual:** ✅ Build estable — versión 1.0.0+3  
**Última actualización:** 10:35 hs (sesión tarde)

---

## 📊 Resumen Ejecutivo

| Métrica                  | Estado                          |
| ------------------------ | ------------------------------- |
| **Build**                | ✅ Estable, compila sin errores |
| **Tests**                | ✅ 196 / 196 pasando            |
| **Errores de analyzer**  | ✅ 0 errores                    |
| **Warnings de analyzer** | ⚠️ 4 warnings (no críticos)     |
| **Archivos de test**     | 12 archivos                     |
| **Fases completadas**    | Fases 1, 2, 3 (≈95%)            |

---

## 📦 Stack Tecnológico

| Componente         | Tecnología                                                 | Estado         |
| ------------------ | ---------------------------------------------------------- | -------------- |
| **App móvil**      | Flutter + Riverpod 2.6.1                                   | ✅ Funcional   |
| **Backend**        | Supabase (PostgreSQL + RPC + RLS)                          | ✅ Funcional   |
| **Edge Functions** | Deno (mercadopago-api, send-notification, generate-avatar) | ✅ Funcional   |
| **Admin Panel**    | Vite + React + TypeScript + Tailwind                       | ✅ Funcional   |
| **CI/CD**          | GitHub Actions                                             | ⚙️ Configurado |

---

## ✅ Problemas Resueltos (historial)

| Problema original                            | Solución aplicada                                                              |
| -------------------------------------------- | ------------------------------------------------------------------------------ |
| Arquitectura inconsistente (auth/stats/etc.) | ✅ Todas las features con `data/domain/presentation` completos                 |
| `SupabaseRpcService` God Object (862 líneas) | ✅ Dividido en 6 servicios: Task, Reward, Stats, Household, Balance, Admin     |
| `main.dart` con 917 líneas y mucha resp.     | ✅ `MainScreen`, `DeepLinkService` extraídos; `MyApp` simplificado             |
| `dynamic _rpc` en repositorio de tasks       | ✅ Tipado con `TaskRpcService`                                                 |
| `ExpenseService` violaba Clean Architecture  | ✅ Modelos y servicio movidos a `features/expenses/`                           |
| Import roto en `staging_e2e_test.dart`       | ✅ Corregido: usa `TaskRpcService` en lugar del servicio monolítico            |
| Sin tests reales                             | ✅ 196 tests en 12 archivos cubriendo modelos, UseCases, repos, providers, E2E |

---

## ⚠️ Warnings Residuales del Analyzer

> [!NOTE]
> El build compila sin errores. Solo quedan `warnings` e `info` que no bloquean la compilación.

| Archivo                                | Tipo    | Descripción                                                                          | Acción            |
| -------------------------------------- | ------- | ------------------------------------------------------------------------------------ | ----------------- |
| `stats_screen.dart` (L335, 1265, 1317) | warning | `_WeeklyDuelCard`, `_ToggleChip`, `_MemberRankCard` — clases privadas sin referencia | Eliminar o usar   |
| `supabase_auth_service.dart` (L135)    | warning | Null comparison innecesaria (`!= null` sobre tipo non-nullable)                      | Limpiar           |
| `user_avatar.dart` (L8-61)             | info    | 20+ `unnecessary_const` en listas estáticas                                          | Auto-fix          |
| `login_screen_test.dart` (L68)         | info    | `noSuchMethod` sin `@override`                                                       | Agregar anotación |
| `backend_integration_test.dart`        | info    | Tipo privado en API pública                                                          | Revisar           |
| `add_task_options_sheet.dart`          | warning | `use_build_context_synchronously` (async gap)                                        | Fix async         |
| `rewards_screen.dart`                  | warning | `use_build_context_synchronously` (async gap)                                        | Fix async         |
| `fix_provider.dart` (L48)              | info    | `print` en código de producción                                                      | Reemplazar        |

---

## 📋 Plan de Mejoras

### Fase 1: Limpieza y Consolidación ✅ COMPLETADA (95%)

| Tarea                                                                 | Estado               |
| --------------------------------------------------------------------- | -------------------- |
| Eliminar `lib/models/`, `lib/services/`, `lib/repositories/` (legacy) | ✅ Hecho             |
| Purga de archivos scratchpad                                          | ✅ Hecho             |
| Refactorizar `SupabaseRpcService` → 6 servicios                       | ✅ Hecho             |
| Extraer `MainScreen` y `DeepLinkService`                              | ✅ Hecho             |
| Migrar `ExpenseService` a `features/expenses/`                        | ✅ Hecho             |
| Migración `.withOpacity()` → `.withValues(alpha:)`                    | ✅ Hecho             |
| Extraer `auth_guard.dart`                                             | ⬜ Pendiente (menor) |

---

### Fase 2: Completar Clean Architecture ✅ COMPLETADA

| Feature     | Repository (interfaz + impl) | UseCases | Providers | Estado   |
| ----------- | ---------------------------- | -------- | --------- | -------- |
| `tasks`     | ✅                           | ✅       | ✅        | ✅ Hecho |
| `expenses`  | ✅                           | ✅       | ✅        | ✅ Hecho |
| `rewards`   | ✅                           | ✅       | ✅        | ✅ Hecho |
| `savings`   | ✅                           | ✅       | ✅        | ✅ Hecho |
| `shopping`  | ✅                           | ✅       | ✅        | ✅ Hecho |
| `auth`      | ✅                           | ✅       | ✅        | ✅ Hecho |
| `dashboard` | ✅                           | ✅       | ✅        | ✅ Hecho |
| `stats`     | ✅                           | —        | ✅        | ✅ Hecho |
| `settings`  | ✅                           | ✅       | ✅        | ✅ Hecho |
| `household` | ✅                           | —        | ✅        | ✅ Hecho |

---

### Fase 3: Testing ✅ COMPLETADA (~95%)

> **196 tests, todos en verde** ✅

#### Cobertura actual — 12 archivos

| Archivo de test                 | Tipo            | Tests | Cobertura                                                                                                                           |
| ------------------------------- | --------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `models_test.dart`              | Unit            | ~40   | `TaskModel`, `ExpenseModel`, `SavingsGoalModel`, `UserModel`, `RewardModel`, `ShoppingItemModel`, `HouseholdModel`, `CategoryModel` |
| `usecases_test.dart`            | Unit            | 9     | `CompleteTaskUseCase`, `CreateTaskUseCase`, `SaveExpenseUseCase` + edge cases                                                       |
| `providers_test.dart`           | Unit (Riverpod) | ~15   | `TaskCategoryFilterNotifier`, `TaskSearchQueryNotifier`, `TaskViewModeNotifier`, lógica de filtros                                  |
| `repositories_test.dart`        | Unit (mock)     | ~15   | `MockExpenseRepository`, `MockTaskRepository` — CRUD, paginación, error handling                                                    |
| `tasks_flow_test.dart`          | Widget          | 1 E2E | Render → expand → completar → verify mock call → snackbar                                                                           |
| `login_screen_test.dart`        | Widget          | ~5    | Render, validaciones, submit                                                                                                        |
| `backend_integration_test.dart` | Pure Dart       | ~50   | Auth, Household, Tasks, Expenses, Rewards, Stats, Transactions                                                                      |
| `rewards_e2e_test.dart`         | E2E (mock)      | ~15   | Completar tarea → ganar coins → canjear reward → balance → affordability                                                            |
| `expense_e2e_test.dart`         | E2E (mock)      | ~10   | Crear gasto → balance → liquidar deuda                                                                                              |
| `onboarding_e2e_test.dart`      | E2E (mock)      | ~10   | Login → Setup → Dashboard → primera tarea                                                                                           |
| `widget_test.dart`              | Widget          | 1     | Smoke test (default Flutter)                                                                                                        |
| `tasks_flow_test.mocks.dart`    | Generated       | —     | Mocks Mockito para `TaskRepository`                                                                                                 |

#### Lo que ya no falta en testing

- ✅ Modelos del dominio (serialización, computed props, equality)
- ✅ UseCases (happy path + edge cases)
- ✅ Providers de Riverpod (filtros, búsqueda, modo de vista)
- ✅ Repositorios con mock (CRUD, paginación, error handling)
- ✅ Flow completo de tareas (widget E2E)
- ✅ Flow de rewards (mock E2E)
- ✅ Flow de expenses (mock E2E)
- ✅ Flow de onboarding (mock E2E)
- ✅ `staging_e2e_test.dart` (corregido — ya compila)

#### Lo que sería nice-to-have (no crítico)

- ⬜ Tests de `TasksNotifier` con `ProviderContainer` + overrides reales
- ⬜ Tests de autenticación (signIn/signOut flow)
- ⬜ Tests de Shopping y Savings providers

---

### Fase 4: Robustez y Calidad ⬜ PRÓXIMA

#### 4.1 — Limpiar warnings residuales (rápido)

| Tarea                                               | Esfuerzo | Impacto |
| --------------------------------------------------- | -------- | ------- |
| Eliminar clases muertas en `stats_screen.dart`      | 5 min    | Medio   |
| Fix `use_build_context_synchronously` (2 files)     | 15 min   | Alto ⚠️ |
| Fix null comparison en `supabase_auth_service.dart` | 2 min    | Bajo    |
| Auto-fix `unnecessary_const` en `user_avatar.dart`  | 1 min    | Bajo    |
| `@override` en `login_screen_test.dart`             | 1 min    | Bajo    |

#### 4.2 — Manejo de errores consistente

- Implementar `Either<Failure, T>` en repositorios (usando `fpdart`)
- Eliminar `try/catch` genéricos en providers → usar `Failure` types
- `ErrorHandler` service centralizado que muestra SnackBars/Dialogs tipados

#### 4.3 — Logging estructurado

- Reemplazar `debugPrint` / `print` por un `Logger` service con niveles
- Integrar con Crashlytics en producción + console en debug
- Custom keys en Crashlytics (userId, householdId, screen)

#### 4.4 — Performance

- Pagination en `expenses` y `activity feed`
- Caching de datos frecuentes (household members, user profile) con TTL
- `AutoDisposeAsyncNotifier` donde sea apropiado
- Revisar queries SQL — índices faltantes

---

### Fase 5: Features y UX ⬜ PENDIENTE

- Avatar animado con video (idle/duel/victory) — `video_player` integrado ✅
- **Splash screen animado**
- **Empty states** y **Skeleton loaders** para cada lista vacía
- **Pull to refresh** universal en todas las listas
- **i18n** — Español/Inglés con archivos ARB
- **Accesibilidad** — Semantics labels, contraste, font scaling

---

### Fase 6: Infraestructura y DevOps ⬜ PENDIENTE

- CI/CD: `flutter analyze` + tests en PR automáticos (ya configurado parcialmente)
- Environments separados: dev / staging / production
- Monitoring: Crashlytics + alertas + Firebase Analytics
- Documentación: `ARCHITECTURE.md`, actualizar `APP_FLOW_V2.md`, documentar RPCs

---

## 📈 Progreso Visual

```
Fase 1 — Limpieza           ████████████████████░   95%
Fase 2 — Clean Architecture █████████████████████  100%
Fase 3 — Testing            ████████████████████░   95%
Fase 4 — Robustez           ░░░░░░░░░░░░░░░░░░░░░    5%
Fase 5 — UX/Features        ████░░░░░░░░░░░░░░░░░   20%
Fase 6 — DevOps             ██░░░░░░░░░░░░░░░░░░░   10%
```

---

## 🔜 Próximos pasos sugeridos (por prioridad)

> [!TIP]
> Con 196 tests en verde y las primeras 3 fases casi completas, el proyecto está en muy buen estado. El foco ahora debería ser **calidad del código existente** antes de agregar features nuevas.

### Prioridad inmediata

1. 🟡 **Fix `use_build_context_synchronously`** en `add_task_options_sheet.dart` y `rewards_screen.dart` — riesgo real de crash en async
2. 🟡 **Eliminar clases muertas** en `stats_screen.dart` (`_WeeklyDuelCard`, `_ToggleChip`, `_MemberRankCard`)
3. 🟢 **Fix null comparison** en `supabase_auth_service.dart` (L135)
4. 🟢 **Auto-fix `unnecessary_const`** en `user_avatar.dart` (`dart fix --apply`)
5. 🟢 **Extraer `auth_guard.dart`** — único pendiente de Fase 1.3

### Next features

- 📊 Stats expandidos (ranking semanal histórico, gráficos de tendencias)
- 🛒 Shopping list offline-first mejorada
- 💬 Comentarios en tareas
- 🔔 Push notifications proactivas (deadline de tarea)
- 🌎 Internacionalización (español/inglés)

---

> [!IMPORTANT]
> **Estado del test suite:** `flutter test test\` → **196 passed, 0 failed** ✅  
> **Estado del analyzer:** `flutter analyze` → **0 errors, 4 warnings** ⚠️
