# Mapa de Providers Riverpod — HomeSync

Documento de referencia con el grafo completo de dependencias entre providers de Riverpod.

---

## Grafo de Dependencias

### Raíz

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `supabaseClientProvider` | `AutoDispose<SupabaseClient>` | — | **ROOT**. Retorna `Supabase.instance.client` |

---

### Capa de Identidad

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `appIdentityServiceProvider` | `ChangeNotifierProvider<AppIdentityService>` | reads `supabaseClientProvider` | Servicio de identidad (Firebase UID → Supabase UUID) |
| `currentUserIdProvider` | `Provider<String?>` | watches `adminProvider`, `appIdentityServiceProvider` | Resuelve Firebase UID → Supabase UUID |
| `householdIdProvider` | `FutureProvider<String?>` | watches `adminProvider`, `currentUserIdProvider`; reads `supabaseClientProvider` | ID del hogar actual — **CENTRAL HUB** |
| `memberOnboardingProvider` | `FutureProvider<bool>` | watches `adminProvider`, `currentUserIdProvider` | Estado de onboarding del miembro |
| `userProfileProvider` | `FutureProvider<Map?>` | watches `adminProvider`, `currentUserIdProvider` | Perfil del usuario actual |
| `userBalanceProvider` | `FutureProvider<Map?>` | watches `householdIdProvider`; reads `rpcServiceProvider` | Balance del usuario |

---

### Feature: Auth

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `firebaseAuthServiceProvider` | `Provider<FirebaseAuthService>` | reads `supabaseClientProvider` | Servicio de autenticación Firebase |
| `authRepositoryProvider` | `Provider<AuthRepository>` | reads `supabaseClientProvider`, `firebaseAuthServiceProvider` | Repositorio de auth |
| `currentUserProvider` | `@riverpod User?` | watches `authRepositoryProvider` | Usuario actual de Firebase |
| `authControllerProvider` | `@riverpod Stream<AuthState>` | watches `authRepositoryProvider` | Stream de estado de autenticación |
| `isAuthenticatedProvider` | `@riverpod bool` | watches `adminProvider`, `authStateProvider` | Flag de autenticación |

---

### Feature: Household

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `householdRepositoryProvider` | `Provider<HouseholdRepository>` | reads `supabaseClientProvider` | Repositorio de hogares |
| `householdMembersNotifierProvider` | `@Riverpod(keepAlive) HouseholdMembersNotifier` | watches `householdIdProvider`; reads `currentUserIdProvider`, `adminProvider`, `householdRepositoryProvider`, `supabaseClientProvider` | Notifier con suscripciones Realtime |
| `householdMembersProvider` | `@Riverpod(keepAlive) HouseholdMembers` | watches `householdMembersNotifierProvider` | Accessor delegado de miembros |
| `currentHouseholdProvider` | `@riverpod Future<HouseholdModel?>` | watches `householdIdProvider`; reads `householdRepositoryProvider` | Modelo del hogar actual |
| `householdCapabilitiesProvider` | `@riverpod HouseholdCapabilities` | watches `adminProvider`, `currentHouseholdProvider` | Capacidades según tipo de hogar |

---

### Feature: Expenses

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `expenseRepositoryProvider` | `@riverpod ExpenseRepository` | watches `supabaseClientProvider` | Repositorio de gastos |
| `expenseControllerProvider` | `@riverpod ExpenseController` | watches `householdIdProvider`; reads `expenseRepositoryProvider`, `isOnlineProvider` | Controlador de gastos |
| `combinedFeedControllerProvider` | `@riverpod CombinedFeedController` | watches `householdIdProvider`, `expenseRepositoryProvider` | Feed combinado (gastos + ingresos) |
| `expenseBalancesProvider` | `@Riverpod(keepAlive) ExpenseBalances` | watches `householdIdProvider` | Balances de gastos (persistente) |
| `personalFinanceSummaryProvider` | `@riverpod PersonalFinanceSummary` | reads `currentUserIdProvider`; watches `householdIdProvider` | Resumen financiero personal |
| `monthlyProjectionProvider` | `@riverpod MonthlyProjectionData` | watches `combinedFeedControllerProvider`, `householdMembersProvider` | Proyección mensual |

---

### Feature: Tasks

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `taskRepositoryProvider` | `@riverpod TaskRepository` | reads `supabaseClientProvider`, `taskRpcServiceProvider` | Repositorio de tareas |
| `tasksProvider` | `@Riverpod(keepAlive) Tasks` | watches `householdIdProvider`; reads `supabaseClientProvider`, `currentUserIdProvider` | Tareas con suscripciones Realtime |
| `filteredTasksProvider` | `@riverpod AsyncValue<List<TaskModel>>` | watches `tasksProvider`, `taskCategoryFilterProvider`, `taskSearchQueryProvider` | Tareas filtradas |
| `todayTasksProvider` | `@riverpod AsyncValue<List<TaskModel>>` | watches `tasksProvider`, `currentUserIdProvider`, `householdCapabilitiesProvider` | Tareas de hoy |

---

### Feature: Stats

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `statsControllerProvider` | `@Riverpod(keepAlive) StatsController` | watches `householdIdProvider` + 7 use case providers | Controlador de estadísticas (persistente) |

---

### Feature: Rewards

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `rewardRepositoryProvider` | `@riverpod RewardRepository` | reads `supabaseClientProvider`, `rewardRpcServiceProvider` | Repositorio de recompensas |
| `rewardsProvider` | `@riverpod Rewards` | watches `householdIdProvider`, `currentHouseholdProvider`; reads `householdMembersProvider` | Recompensas con suscripciones Realtime |

---

### Feature: Shopping

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `shoppingItemsProvider` | `@Riverpod(keepAlive) ShoppingItems` | watches `householdIdProvider`; reads `supabaseClientProvider`, `currentUserIdProvider` | Items de compra con suscripciones Realtime |

---

### Feature: Dashboard

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `recentActivityProvider` | `@Riverpod(keepAlive) Stream<List<Map>>` | watches `householdIdProvider`, `currentUserIdProvider` | Stream de actividad reciente |

---

### Infraestructura

| Provider | Tipo | Dependencias | Descripción |
|---|---|---|---|
| `adminProvider` | `NotifierProvider<AdminNotifier, AdminState>` | — | Standalone. Inyectado en casi todos los providers para override de QA |
| `connectivityNotifierProvider` | `@Riverpod(keepAlive) ConnectivityNotifier` | — | Estado online/offline |
| `isOnlineProvider` | `@riverpod bool` | watches `connectivityNotifierProvider` | Flag de conectividad |

---

### RPC Service Providers

Todos dependen de `supabaseClientProvider`:

| Provider | Descripción |
|---|---|
| `adminRpcServiceProvider` | RPCs de administración |
| `balanceRpcServiceProvider` | RPCs de balances |
| `householdRpcServiceProvider` | RPCs de hogares |
| `rewardRpcServiceProvider` | RPCs de recompensas |
| `statsRpcServiceProvider` | RPCs de estadísticas |
| `taskRpcServiceProvider` | RPCs de tareas |

---

## Camino Crítico

```
supabaseClientProvider (ROOT)
  → appIdentityServiceProvider → currentUserIdProvider
    → householdIdProvider (CENTRAL HUB)
      → householdMembersNotifierProvider (Realtime)
      → tasksProvider (Realtime)
      → expenseControllerProvider
      → shoppingItemsProvider (Realtime)
      → rewardsProvider (Realtime)
      → statsControllerProvider
      → recentActivityProvider
      → userBalanceProvider
      → personalFinanceSummaryProvider
```

`householdIdProvider` es el nodo central del que dependen todos los features principales. Si falla la resolución de identidad, **ningún feature funcional funciona**.

---

## Patrones Clave

1. **Repository → Use Case → Controller**: Cada feature sigue este patrón de 3 capas
2. **Providers keepAlive**: `tasksProvider`, `householdMembersProvider`, `shoppingItemsProvider`, `expenseBalancesProvider`, `statsControllerProvider`, `rewardsProvider` — se suscriben a Supabase Realtime y persisten a través de la navegación
3. **Admin testing**: `adminProvider` es watcheado por casi todos los providers para permitir override en QA
4. **isOnline**: Leído (no watcheado) por los controllers para gatear llamadas `invalidateSelf()` y soportar modo offline

---

## Convenciones de Lectura

- **watches** = se suscribe a cambios (rebuild automático cuando el provider observado cambia)
- **reads** = lee el valor una sola vez sin suscribirse (sin rebuild automático)
- **Realtime** = el provider mantiene una suscripción activa a Supabase Realtime (`.onPostgresChange()`)
- **keepAlive** = el provider sobrevive a la navegación y no se auto-dispose
