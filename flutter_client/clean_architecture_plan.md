# 🏗️ Plan: Clean Architecture Completa — HomeSync App

> **Objetivo:** Migrar la totalidad de la app al patrón Clean Architecture con Feature-First, Repository Pattern y Use Cases. Cada feature es un módulo independiente y autocontenido.

---

## 📐 Estructura Target Final

```
lib/
├── core/                          ← Infraestructura compartida (sin negocio)
│   ├── constants/
│   │   └── app_constants.dart     ← Strings, duraciones, etc.
│   ├── errors/
│   │   └── failures.dart          ← Clases de error tipadas
│   ├── providers/
│   │   └── supabase_provider.dart ← SupabaseClient como provider inyectable
│   ├── theme/                     ← (mover desde lib/theme/)
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── utils/                     ← (mover desde lib/utils/)
│       └── app_animations.dart
│
├── features/
│   ├── auth/                      ✅ FASE 1
│   │   ├── domain/
│   │   │   ├── models/user_model.dart
│   │   │   ├── repositories/auth_repository.dart   (interfaz abstracta)
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   ├── data/
│   │   │   └── repositories/supabase_auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/auth_provider.dart
│   │       └── screens/login_screen.dart
│   │
│   ├── household/                 ✅ FASE 1 (núcleo compartido)
│   │   ├── domain/
│   │   │   ├── models/household_model.dart
│   │   │   ├── models/member_model.dart
│   │   │   ├── repositories/household_repository.dart (interfaz)
│   │   │   └── usecases/
│   │   │       └── get_household_usecase.dart
│   │   ├── data/
│   │   │   └── repositories/supabase_household_repository.dart
│   │   └── presentation/
│   │       ├── providers/household_provider.dart
│   │       └── screens/
│   │           ├── setup_screen.dart
│   │           └── members_screen.dart
│   │
│   ├── tasks/                     ✅ FASE 2
│   │   ├── domain/
│   │   │   ├── models/task_model.dart         ← (mover/refactorizar models/task.dart)
│   │   │   ├── repositories/task_repository.dart (interfaz)
│   │   │   └── usecases/
│   │   │       ├── get_tasks_usecase.dart
│   │   │       ├── complete_task_usecase.dart
│   │   │       └── create_task_usecase.dart
│   │   ├── data/
│   │   │   └── repositories/supabase_task_repository.dart
│   │   └── presentation/
│   │       ├── providers/task_provider.dart   ← (refactorizar task_providers.dart)
│   │       ├── screens/tasks_screen.dart
│   │       └── widgets/
│   │           ├── task_card.dart
│   │           ├── create_task_dialog.dart
│   │           ├── complete_task_sheet.dart
│   │           ├── edit_task_sheet.dart
│   │           ├── task_detail_sheet.dart
│   │           └── add_task_options_sheet.dart
│   │
│   ├── expenses/                  ✅ FASE 3
│   │   ├── domain/
│   │   │   ├── models/expense_model.dart      ← (refactorizar models/expense.dart)
│   │   │   ├── repositories/expense_repository.dart (interfaz)
│   │   │   └── usecases/
│   │   │       ├── get_expenses_usecase.dart
│   │   │       └── add_expense_usecase.dart
│   │   ├── data/
│   │   │   └── repositories/supabase_expense_repository.dart ← (refactorizar repositories/expense_repository.dart)
│   │   └── presentation/
│   │       ├── providers/expense_provider.dart
│   │       ├── screens/expenses_screen.dart
│   │       └── widgets/
│   │           └── expense_form_sheet.dart
│   │
│   ├── rewards/                   ✅ YA HECHO (FASE 0)
│   │   ├── domain/
│   │   │   ├── models/reward_model.dart       ✅
│   │   │   ├── repositories/rewards_repository_interface.dart  ← PENDIENTE (interfaz abstracta)
│   │   │   └── usecases/                      ← PENDIENTE
│   │   │       ├── get_rewards_usecase.dart
│   │   │       └── redeem_reward_usecase.dart
│   │   ├── data/
│   │   │   └── repositories/rewards_repository.dart ✅
│   │   └── presentation/
│   │       ├── providers/rewards_provider.dart ✅
│   │       └── screens/rewards_screen.dart    ✅
│   │
│   ├── savings/                   ✅ FASE 4
│   │   ├── domain/
│   │   │   ├── models/savings_goal_model.dart ← (refactorizar models/savings_goal.dart)
│   │   │   ├── repositories/savings_repository.dart (interfaz)
│   │   │   └── usecases/
│   │   │       └── get_savings_usecase.dart
│   │   ├── data/
│   │   │   └── repositories/supabase_savings_repository.dart
│   │   └── presentation/
│   │       ├── providers/savings_provider.dart
│   │       └── screens/savings_screen.dart
│   │
│   └── shopping/                  ✅ FASE 4
│       ├── domain/
│       │   ├── models/shopping_item_model.dart
│       │   ├── repositories/shopping_repository.dart (interfaz)
│       │   └── usecases/
│       │       └── get_shopping_list_usecase.dart
│       ├── data/
│       │   └── repositories/supabase_shopping_repository.dart
│       └── presentation/
│           ├── providers/shopping_provider.dart
│           └── screens/shopping_list_screen.dart
│
├── shared/                        ← Widgets reutilizables entre features
│   └── widgets/
│       ├── user_avatar.dart
│       ├── balance_card.dart
│       ├── schedule_dialog.dart
│       ├── faceoff_widget.dart
│       ├── custom_bottom_nav.dart
│       ├── mercadopago_settings_card.dart
│       └── avatar_picker_sheet.dart
│
└── main.dart
```

---

## 🔑 Principio clave: Interfaces Abstractas

Cada feature tendrá en `domain/repositories/` una **interfaz abstracta** (contrato):

```dart
// features/tasks/domain/repositories/task_repository.dart
abstract class TaskRepository {
  Future<List<TaskModel>> getTasks(String householdId);
  Future<void> completeTask(String taskId, int coinsEarned);
  Future<void> createTask(TaskModel task);
}
```

Y la implementación real irá en `data/repositories/`:

```dart
// features/tasks/data/repositories/supabase_task_repository.dart
class SupabaseTaskRepository implements TaskRepository {
  // Solo aquí sabe que existe Supabase
}
```

Esto garantiza que el día que cambies de Supabase → Firebase, solo cambiás **la implementación**, nunca el dominio.

---

## 🎯 Use Cases (Casos de Uso)

Cada operación de negocio es una clase con un único método `call()`:

```dart
// features/tasks/domain/usecases/complete_task_usecase.dart
class CompleteTaskUseCase {
  final TaskRepository _repository;
  CompleteTaskUseCase(this._repository);

  Future<void> call(String taskId, int coins) async {
    // Aquí van las reglas de negocio:
    // ¿Está activa la tarea? ¿El usuario tiene permisos?
    // ¿Se pueden asignar tantos coins?
    await _repository.completeTask(taskId, coins);
  }
}
```

El Provider consume Use Cases, no el Repositorio directamente.

---

## **Fase 4: Savings y Shopping (¡COMPLETADA!)**

✅ **Por qué juntos**: Comparten características de listas pequeñas (metas que se llenan o ítems que se tildan).
✅ **Qué hacemos**:

- `features/savings/` y `features/shopping/`.
- Casos de uso de progreso financiero y tildes rápidos.
- Cero dependencias externas salvo `core/`.

---

## **Fase 5: Cleanup y Eliminación de Carpetas Viejas (¡PRÓXIMO!)**

---

## 📋 Fases de Migración

| Fase | Estado | Descripción |
208: | ----- | -------- | -------------------------------------------------------------------------------------------- |
| **0** | ✅ Hecho | Análisis y plan de acción. Eliminación de código obsoleto. Completar Rewards con Use Cases. |
| **1** | ✅ Hecho | Creación de `core/` (Services, Models base), Migración completa de **Auth** y **Household**. |
| **2** | ✅ Hecho | Migración de **Tasks** (Feature + Complejo). |
| **3** | ✅ Hecho | Migración de **Expenses** (Complejidad media alta). |
| **4** | ✅ Hecho | Migración de **Savings** y **Shopping** (Listas y Progreso). |
| **5** | ✅ Hecho | Limpieza final: BORRAR `/models`, `/providers`, `/repositories`, `/screens` viejos. |

---

## ⚠️ Reglas de oro durante la migración

1. **Nunca romper la app**: Cada fase debe entregar una app compilable y funcional.
2. **Un feature a la vez**: No empezar la siguiente fase hasta verificar que la anterior compila.
3. **Los imports apuntan "hacia adentro"**: La presentación conoce al dominio, el dominio NO conoce a la presentación ni a los datos.
4. **Inyección de dependencias via Riverpod**: Los repositorios concretos se inyectan en los providers como `Provider<TaskRepository>`, nunca se instancian directamente.

---

## 🏁 Checklist de Completación por Feature

### rewards (Fase 0 → completar)

- [x] `domain/models/reward_model.dart`
- [x] `domain/repositories/rewards_repository_interface.dart`
- [x] `domain/usecases/get_rewards_usecase.dart`
- [x] `domain/usecases/redeem_reward_usecase.dart`
- [x] `domain/usecases/suggest_reward_usecase.dart`
- [x] `data/repositories/rewards_repository.dart`
- [x] `presentation/providers/rewards_provider.dart`
- [x] `presentation/screens/rewards_screen.dart`

### core

- [x] `core/constants/app_constants.dart`
- [x] `core/errors/failures.dart`
- [x] `core/providers/supabase_provider.dart`
- [x] Mover `theme/` → `core/theme/`
- [x] Mover `utils/` → `core/utils/`

### auth

- [x] `domain/models/user_model.dart`
- [x] `domain/repositories/auth_repository.dart` (interfaz)
- [x] `domain/usecases/login_usecase.dart`
- [x] `domain/usecases/logout_usecase.dart`
- [x] `data/repositories/supabase_auth_repository.dart`
- [x] `presentation/providers/auth_provider.dart`
- [x] `presentation/screens/login_screen.dart`

### household

- [x] `domain/models/household_model.dart`
- [x] `domain/repositories/household_repository.dart`
- [x] `data/repositories/supabase_household_repository.dart`
- [x] `presentation/providers/household_provider.dart`

### tasks

- [x] `domain/models/task_model.dart`
- [x] `domain/repositories/task_repository.dart` (interfaz)
- [x] `domain/usecases/get_tasks_usecase.dart`
- [x] `domain/usecases/complete_task_usecase.dart`
- [x] `domain/usecases/create_task_usecase.dart`
- [x] `data/repositories/supabase_task_repository.dart`
- [x] `presentation/providers/task_provider.dart`
- [x] `presentation/screens/tasks_screen.dart`
- [x] `presentation/widgets/` (6 archivos de tasks)

### expenses

- [x] `domain/models/expense_model.dart`
- [x] `domain/repositories/expense_repository.dart` (interfaz)
- [x] `domain/usecases/get_expenses_usecase.dart`
- [x] `domain/usecases/add_expense_usecase.dart`
- [x] `data/repositories/supabase_expense_repository.dart`
- [x] `presentation/providers/expense_provider.dart`
- [x] `presentation/screens/expenses_screen.dart`
- [x] `presentation/widgets/expense_form_sheet.dart`

### savings

- [x] `domain/models/savings_goal_model.dart`
- [x] `domain/repositories/savings_repository.dart` (interfaz)
- [x] `domain/usecases/get_savings_usecase.dart`
- [x] `data/repositories/supabase_savings_repository.dart`
- [x] `presentation/providers/savings_provider.dart`
- [x] `presentation/screens/savings_screen.dart`

### shopping

- [x] `domain/models/shopping_item_model.dart`
- [x] `domain/repositories/shopping_repository.dart` (interfaz)
- [x] `domain/usecases/get_shopping_list_usecase.dart`
- [x] `data/repositories/supabase_shopping_repository.dart`
- [x] `presentation/providers/shopping_provider.dart`
- [x] `presentation/screens/shopping_list_screen.dart`
