# 🏗️ HomeSync Flutter - Clean Architecture

**Fecha de migración:** 2026-03-01
**Commit:** 124312b - "refactor: complete clean architecture migration and fix imports"
**Estado:** ✅ COMPLETADO

---

## 📊 Diagrama General

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    UI LAYER                            │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │   │
│  │  │ Screens  │  │ Widgets  │  │ Providers│           │   │
│  │  └──────────┘  └──────────┘  └──────────┘           │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────────┬────────────────────────────────┘
                                 │ Riverpod
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DOMAIN LAYER                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    USE CASES                            │   │
│  │  ┌──────────────────┐  ┌──────────────────────────┐   │   │
│  │  │TaskUseCases       │  │ExpenseUseCases         │   │   │
│  │  │- createTask      │  │- saveExpense           │   │   │
│  │  │- completeTask    │  │- deleteExpense         │   │   │
│  │  │- getTasks        │  │- getBalances           │   │   │
│  │  └──────────────────┘  └──────────────────────────┘   │   │
│  │  ┌──────────────────┐  ┌──────────────────────────┐   │   │
│  │  │RewardUseCases    │  │ShoppingUseCases        │   │   │
│  │  │- redeemReward    │  │- addItem               │   │   │
│  │  │- getRewards      │  │- toggleItem            │   │   │
│  │  └──────────────────┘  └──────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                 │
│                              ▼                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    MODELS                               │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │   │
│  │  │ TaskModel│  │ExpenseModel│ │RewardModel│           │   │
│  │  └──────────┘  └──────────┘  └──────────┘           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                 │
│                              ▼                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 REPOSITORIES (Interfaces)                  │   │
│  │  ┌──────────────────┐  ┌──────────────────────────┐   │   │
│  │  │TaskRepository     │  │ExpenseRepository         │   │   │
│  │  │RewardRepository   │  │ShoppingRepository         │   │   │
│  │  │SavingsRepository  │  │HouseholdRepository        │   │   │
│  │  └──────────────────┘  └──────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DATA LAYER                                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               REPOSITORIES (Implementations)             │   │
│  │  ┌──────────────────┐  ┌──────────────────────────┐   │   │
│  │  │SupabaseTaskRepo   │  │SupabaseExpenseRepo       │   │   │
│  │  │SupabaseRewardRepo │  │SupabaseShoppingRepo       │   │   │
│  │  │SupabaseSavingsRepo│  │SupabaseHouseholdRepo      │   │   │
│  │  └──────────────────┘  └──────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                 │
│                              ▼                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   DATA SOURCES                            │   │
│  │  ┌──────────────────┐  ┌──────────────────────────┐   │   │
│  │  │Supabase Client   │  │SharedPreferences          │   │   │
│  │  └──────────────────┘  └──────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Estructura de Directorios

```
flutter_client/lib/
├── main.dart                          # Entry point
│
├── core/                             # CORE LAYER
│   ├── constants/                     # Constants
│   │   └── app_constants.dart
│   ├── errors/                        # Errors & Failures
│   │   └── failures.dart
│   ├── providers/                     # Global Providers (Riverpod)
│   │   ├── core_providers.dart
│   │   ├── supabase_provider.dart
│   │   └── theme_provider.dart
│   ├── services/                      # Core Services (Cross-cutting)
│   │   ├── expense_service.dart        # ✅ Migrated to feature
│   │   ├── mercadopago_service.dart
│   │   ├── notification_service.dart
│   │   ├── shopping_service.dart      # ✅ Migrated to feature
│   │   ├── supabase_auth_service.dart
│   │   ├── supabase_rpc_service.dart   # RPC Functions (Core)
│   │   └── template_service.dart
│   ├── theme/                         # Theme & Design System
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── app_theme_extension.dart
│   └── utils/                         # Utilities
│       └── app_animations.dart
│
├── features/                          # FEATURE LAYER (Clean Arch)
│   │
│   ├── auth/                          # AUTH FEATURE
│   │   ├── data/                      # Data Layer
│   │   │   └── repositories/
│   │   │       └── supabase_auth_repository.dart
│   │   ├── domain/                    # Domain Layer
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/              # Presentation Layer
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           └── onboarding_screen.dart
│   │
│   ├── dashboard/                     # DASHBOARD FEATURE
│   │   └── presentation/
│   │       └── screens/
│   │           └── home_screen.dart
│   │
│   ├── expenses/                      # EXPENSES FEATURE
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── supabase_expense_repository.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── expense_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── expense_repository.dart
│   │   │   └── usecases/
│   │   │       ├── delete_expense_usecase.dart
│   │   │       ├── get_balances_usecase.dart
│   │   │       ├── get_expenses_usecase.dart
│   │   │       ├── save_expense_usecase.dart
│   │   │       └── settle_debt_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── expense_provider.dart
│   │       ├── screens/
│   │       │   └── expenses_screen.dart
│   │       └── widgets/
│   │           └── expense_form_sheet.dart
│   │
│   ├── household/                     # HOUSEHOLD FEATURE
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── supabase_household_repository.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── household_model.dart
│   │   │   │   └── member.dart
│   │   │   └── repositories/
│   │   │       └── household_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── household_provider.dart
│   │       │   └── household_providers.dart
│   │       └── screens/
│   │           ├── members_screen.dart
│   │           └── setup_screen.dart
│   │
│   ├── rewards/                       # REWARDS FEATURE
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── rewards_repository.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── reward_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── rewards_repository_interface.dart
│   │   │   └── usecases/
│   │   │       ├── get_rewards_usecase.dart
│   │   │       ├── redeem_reward_usecase.dart
│   │   │       └── suggest_reward_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── rewards_provider.dart
│   │       └── screens/
│   │           └── rewards_screen.dart
│   │
│   ├── savings/                       # SAVINGS FEATURE
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── supabase_savings_repository.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   └── savings_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── savings_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_contribution_usecase.dart
│   │   │       ├── create_savings_goal_usecase.dart
│   │   │       ├── delete_savings_goal_usecase.dart
│   │   │       ├── get_goal_contributions_usecase.dart
│   │   │       └── get_savings_goals_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── savings_provider.dart
│   │       │   └── savings_providers.dart
│   │       └── screens/
│   │           └── savings_screen.dart
│   │
│   ├── shopping/                      # SHOPPING FEATURE
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── supabase_shopping_repository.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── shopping_categories.dart
│   │   │   │   └── shopping_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── shopping_repository.dart
│   │   │   └── usecases/
│   │   │       ├── add_shopping_item_usecase.dart
│   │   │       ├── clear_completed_shopping_items_usecase.dart
│   │   │       ├── delete_shopping_item_usecase.dart
│   │   │       ├── get_shopping_items_usecase.dart
│   │   │       ├── toggle_shopping_item_usecase.dart
│   │   │       └── uncomplete_all_shopping_items_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── shopping_provider.dart
│   │       ├── screens/
│   │       │   └── shopping_list_screen.dart
│   │       └── widgets/
│   │           ├── add_item_sheet.dart
│   │           └── shopping_item_card.dart
│   │
│   ├── tasks/                         # TASKS FEATURE
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── supabase_task_repository.dart
│   │   ├── domain/
│   │   │   ├── models/
│   │   │   │   ├── category_model.dart
│   │   │   │   └── task_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── task_repository.dart
│   │   │   └── usecases/
│   │   │       ├── complete_task_usecase.dart
│   │   │       ├── create_task_usecase.dart
│   │   │       └── get_tasks_usecase.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── category_providers.dart
│   │       │   └── task_provider.dart
│   │       ├── screens/
│   │       │   ├── calendar_screen.dart
│   │       │   ├── tasks_screen.dart
│   │       │   └── weekly_winner_screen.dart
│   │       └── widgets/
│   │           ├── add_task_options_sheet.dart
│   │           ├── complete_task_sheet.dart
│   │           ├── create_task_dialog.dart
│   │           ├── edit_task_sheet.dart
│   │           ├── task_card.dart
│   │           └── task_detail_sheet.dart
│   │
│   ├── stats/                         # STATS FEATURE
│   │   └── presentation/
│   │       └── screens/
│   │           └── stats_screen.dart
│   │
│   ├── settings/                      # SETTINGS FEATURE
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       └── widgets/
│   │           └── faq_sheet.dart
│   │
│   └── notifications/                 # NOTIFICATIONS FEATURE
│       └── presentation/
│           └── screens/
│               └── notifications_screen.dart
│
├── shared/                           # SHARED COMPONENTS (Reusable)
│   └── widgets/
│       ├── add_task_options_sheet.dart
│       ├── avatar_picker_sheet.dart
│       ├── balance_card.dart
│       ├── complete_task_sheet.dart
│       ├── create_task_dialog.dart
│       ├── custom_bottom_nav.dart
│       ├── edit_task_sheet.dart
│       ├── faceoff_widget.dart
│       ├── mercadopago_settings_card.dart
│       ├── schedule_dialog.dart
│       ├── task_card.dart
│       ├── task_detail_sheet.dart
│       └── user_avatar.dart
│
├── config/                           # CONFIGURATION
│   └── app_environment.dart
│
├── data/                             # SHARED DATA LAYER
│   └── repositories/
│       └── shopping_repository.dart
│
└── models/                           # SHARED MODELS
    └── (deprecated - moved to features/domain/models)
```

---

## 🔄 Flujo de Datos

### Ejemplo: Completar Tarea

```
┌─────────────────────────────────────────────────────────────┐
│ 1. PRESENTATION LAYER                                     │
│    ┌─────────────────────────────────────────────────────┐  │
│    │ task_provider.dart (Riverpod)                      │  │
│    │ completeTask(taskId, userId)                        │  │
│    └─────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. DOMAIN LAYER - USE CASES                                │
│    ┌─────────────────────────────────────────────────────┐  │
│    │ complete_task_usecase.dart                           │  │
│    │ execute(taskId, userId)                              │  │
│    │   1. Validar input                                  │  │
│    │   2. Llamar a TaskRepository                       │  │
│    └─────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. DOMAIN LAYER - REPOSITORY (Interface)                    │
│    ┌─────────────────────────────────────────────────────┐  │
│    │ task_repository.dart                                  │  │
│    │ completeTask(taskId, userId)                          │  │
│    └─────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. DATA LAYER - REPOSITORY (Implementation)                 │
│    ┌─────────────────────────────────────────────────────┐  │
│    │ supabase_task_repository.dart                         │  │
│    │ completeTask(taskId, userId)                          │  │
│    │   1. Llamar a Supabase RPC                          │  │
│    │   2. Manejar errores                                  │  │
│    │   3. Retornar TaskModel                              │  │
│    └─────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. EXTERNAL DATA SOURCE                                     │
│    ┌─────────────────────────────────────────────────────┐  │
│    │ Supabase (RPC Functions)                             │  │
│    │ complete_task(taskId, userId)                          │  │
│    │   - Validar RLS policies                              │  │
│    │   - Ejecutar lógica en PostgreSQL                     │  │
│    │   - Actualizar tabla tasks                            │  │
│    │   - Actualizar tabla ledger_entries                    │  │
│    │   - Disparar triggers de notificación                  │  │
│    └─────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. REALTIME UPDATES (Supabase Realtime)                    │
│    ┌─────────────────────────────────────────────────────┐  │
│    │ tasks table (PostgreSQL)                            │  │
│    │   → UPDATE triggers Realtime channel                │  │
│    │   → Flutter client receives update                  │  │
│    │   → TaskProvider automatically refreshes             │  │
│    └─────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. PRESENTATION LAYER (UI Update)                          │
│    ┌─────────────────────────────────────────────────────┐  │
│    │ task_provider.dart (Riverpod)                        │  │
│    │   → State updates automatically                      │  │
│    │   → Widgets rebuild with new data                    │  │
│    └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Responsabilidades por Capa

### PRESENTATION LAYER (features/*/presentation/)
**Responsabilidades:**
- ✅ UI Components (Screens, Widgets)
- ✅ State Management (Riverpod Providers)
- ✅ User Input Handling
- ✅ Display Data to User
- ✅ Handle User Gestures

**NO debe:**
- ❌ Contener lógica de negocio
- ❌ Acceder directamente a APIs externas
- ❌ Conocer sobre la implementación de repositorios
- ❌ Conocer sobre la estructura de datos externa

### DOMAIN LAYER (features/*/domain/)
**Responsabilidades:**
- ✅ Business Logic (Use Cases)
- ✅ Domain Models (Pure Dart classes)
- ✅ Repository Interfaces (Abstractions)
- ✅ Business Rules
- ✅ Value Objects

**NO debe:**
- ❌ Depender de frameworks (Flutter, Riverpod)
- ❌ Acceder a APIs externas
- ❌ Contener código UI
- ❌ Conocer sobre la implementación de datos

### DATA LAYER (features/*/data/)
**Responsabilidades:**
- ✅ Repository Implementations
- ✅ Data Sources (Supabase, SharedPreferences)
- ✅ Data Mapping (DTO → Domain Model)
- ✅ Error Handling for data operations

**NO debe:**
- ❌ Contener lógica de negocio
- ❌ Conocer sobre UI
- ❌ Exponer estructuras de datos externas

---

## 📦 Patrones Implementados

### 1. Repository Pattern
```dart
// DOMAIN LAYER - Interface
abstract class TaskRepository {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> getTask(String id);
  Future<void> createTask(TaskModel task);
  Future<void> completeTask(String taskId, String userId);
}

// DATA LAYER - Implementation
class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient _client;

  @override
  Future<List<TaskModel>> getTasks() async {
    final response = await _client.rpc('get_tasks');
    return response.map((e) => TaskModel.fromJson(e)).toList();
  }
}
```

### 2. Use Case Pattern
```dart
// DOMAIN LAYER
class CompleteTaskUseCase {
  final TaskRepository _repository;

  CompleteTaskUseCase(this._repository);

  Future<void> execute(String taskId, String userId) async {
    // 1. Validar input
    if (taskId.isEmpty || userId.isEmpty) {
      throw ValidationException('Invalid input');
    }

    // 2. Llamar a repository
    await _repository.completeTask(taskId, userId);
  }
}
```

### 3. Provider Pattern (Riverpod)
```dart
// PRESENTATION LAYER
final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(
    repository: ref.watch(taskRepositoryProvider),
    completeTaskUseCase: ref.watch(completeTaskUseCaseProvider),
  );
});
```

### 4. DTO Pattern
```dart
// DOMAIN MODEL (Rich)
class TaskModel {
  final String id;
  final String title;
  final String status;
  final TaskCategory category;

  TaskModel({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      category: TaskCategory.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'category': category.toJson(),
    };
  }
}
```

---

## 🎨 Beneficios de esta Arquitectura

### ✅ Testabilidad
- **Domain Layer**: Test unitario sin dependencias
- **Use Cases**: Test de lógica de negocio aislado
- **Repositories**: Mock fácil para test UI

### ✅ Mantenibilidad
- **Separación de responsabilidades**: Cada capa tiene su propósito claro
- **Feature-based structure**: Cada feature es independiente
- **Fácil localizar bugs**: Error de datos → Data layer, Error UI → Presentation

### ✅ Escalabilidad
- **Agregar nuevos features**: Copiar estructura de feature existente
- **Reemplazar data source**: Cambiar implementación de repository sin afectar UI
- **Agregar nuevos casos de uso**: Crear nuevo use case en domain

### ✅ Colaboración
- **Trabajo en paralelo**: Diferentes desarrolladores pueden trabajar en diferentes features
- **Reutilización**: Shared widgets se usan en múltiples features
- **Consistencia**: Todos los features siguen el mismo patrón

---

## 📊 Estadísticas de la Migración

### Commit 124312b - Resumen
```
Files Changed: 135
Insertions: 11,226
Deletions: 3,162

New Features Created:
✅ Auth (Login, Onboarding)
✅ Expenses (CRUD, Balances, Settlement)
✅ Rewards (Redeem, Suggest)
✅ Savings (Goals, Contributions)
✅ Shopping (Add, Toggle, Delete)
✅ Tasks (Create, Complete, Get)
✅ Dashboard (Home Screen)
✅ Settings (Configuration)

New Layers Created:
✅ Domain Layer (Use Cases, Models, Repositories)
✅ Data Layer (Repository Implementations)
✅ Presentation Layer (Providers, Screens, Widgets)

Shared Components:
✅ 12 reusable widgets in /lib/shared/widgets/

Core Services:
✅ 7 services in /lib/core/services/
```

---

## 🚀 Guía para Agregar Nuevas Features

### Paso 1: Crear estructura del feature
```bash
flutter_client/lib/features/new_feature/
├── data/
│   └── repositories/
│       └── supabase_new_feature_repository.dart
├── domain/
│   ├── models/
│   │   └── new_feature_model.dart
│   ├── repositories/
│   │   └── new_feature_repository.dart
│   └── usecases/
│       ├── get_new_feature_usecase.dart
│       └── save_new_feature_usecase.dart
└── presentation/
    ├── providers/
    │   └── new_feature_provider.dart
    ├── screens/
    │   └── new_feature_screen.dart
    └── widgets/
        └── new_feature_widget.dart
```

### Paso 2: Implementar Domain Model
```dart
class NewFeatureModel {
  final String id;
  final String title;
  // ... otras propiedades

  NewFeatureModel({
    required this.id,
    required this.title,
  });

  factory NewFeatureModel.fromJson(Map<String, dynamic> json) {
    return NewFeatureModel(
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}
```

### Paso 3: Crear Repository Interface
```dart
abstract class NewFeatureRepository {
  Future<List<NewFeatureModel>> getAll();
  Future<NewFeatureModel?> getById(String id);
  Future<void> create(NewFeatureModel model);
  Future<void> update(String id, NewFeatureModel model);
  Future<void> delete(String id);
}
```

### Paso 4: Implementar Repository
```dart
class SupabaseNewFeatureRepository implements NewFeatureRepository {
  final SupabaseClient _client;

  SupabaseNewFeatureRepository(this._client);

  @override
  Future<List<NewFeatureModel>> getAll() async {
    final response = await _client.from('new_feature_table').select();
    return response.map((e) => NewFeatureModel.fromJson(e)).toList();
  }

  // ... implementar otros métodos
}
```

### Paso 5: Crear Use Cases
```dart
class GetAllNewFeatureUseCase {
  final NewFeatureRepository _repository;

  GetAllNewFeatureUseCase(this._repository);

  Future<List<NewFeatureModel>> execute() {
    return _repository.getAll();
  }
}
```

### Paso 6: Crear Provider
```dart
final newFeatureProvider =
    StateNotifierProvider<NewFeatureNotifier, NewFeatureState>((ref) {
  return NewFeatureNotifier(
    repository: ref.watch(newFeatureRepositoryProvider),
    getAllUseCase: ref.watch(getAllNewFeatureUseCaseProvider),
  );
});
```

### Paso 7: Crear Screen
```dart
class NewFeatureScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newFeatureProvider);

    return Scaffold(
      body: state.when(
        data: (items) => ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(items[index].title),
            );
          },
        ),
        loading: () => CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
```

---

## 📝 Notas Importantes

### Services en `/lib/core/services/`
- **supabase_rpc_service.dart**: Servicio central para llamar a RPC functions de Supabase
- **supabase_auth_service.dart**: Servicio para autenticación
- **notification_service.dart**: Servicio para notificaciones
- **mercadopago_service.dart**: Servicio para integración MercadoPago

Estos servicios son CROSS-CUTTING y son usados por múltiples features.

### Shared Widgets en `/lib/shared/widgets/`
- Componentes reutilizables que NO pertenecen a un feature específico
- Se usan en múltiples features
- Ejemplos: task_card.dart, balance_card.dart, avatar_picker_sheet.dart

### Providers en `/lib/core/providers/`
- Providers GLOBALES (Supabase, Theme, etc.)
- No feature-specific

---

## 🔍 Convenciones de Código

### Nomenclatura
- **Files**: snake_case (ej: `task_model.dart`)
- **Classes**: PascalCase (ej: `TaskModel`)
- **Methods**: camelCase (ej: `getTasks()`)
- **Variables**: camelCase (ej: `taskId`)
- **Constants**: UPPER_SNAKE_CASE (ej: `MAX_RETRIES`)

### Imports
```dart
// 1. Dart core
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Paquetes externos
import 'package:supabase_flutter/supabase_flutter.dart';

// 5. Core del proyecto
import '../../../core/services/supabase_rpc_service.dart';

// 6. Domain del feature
import '../domain/models/task_model.dart';
import '../domain/repositories/task_repository.dart';
```

---

## 🎓 Conclusión

Esta Clean Architecture implementada en Flutter sigue principios SOLID:

✅ **Single Responsibility**: Cada clase tiene una única responsabilidad
✅ **Open/Closed**: Abierto para extensión, cerrado para modificación
✅ **Liskov Substitution**: Interfaces son respetadas
✅ **Interface Segregation**: Interfaces específicas y pequeñas
✅ **Dependency Inversion**: Capas de alto nivel no dependen de capas de bajo nivel

La arquitectura hace que el código sea:
- ✅ Testable
- ✅ Mantenible
- ✅ Escalable
- ✅ Colaborativo

---

**Última actualización:** 2026-03-02
**Autor:** Migración completada en commit 124312b
**Estado:** ✅ Producción funcional (Nivel 3 con Clean Architecture)
