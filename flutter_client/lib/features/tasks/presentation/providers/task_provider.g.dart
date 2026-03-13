// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getTasksUseCaseHash() => r'87dc118144b883d9068381fd14c4ea5a34b69362';

/// See also [getTasksUseCase].
@ProviderFor(getTasksUseCase)
final getTasksUseCaseProvider = AutoDisposeProvider<GetTasksUseCase>.internal(
  getTasksUseCase,
  name: r'getTasksUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getTasksUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetTasksUseCaseRef = AutoDisposeProviderRef<GetTasksUseCase>;
String _$completeTaskUseCaseHash() =>
    r'efb67b39b2602c68f3ca08eb2c8c49409e1db9b1';

/// See also [completeTaskUseCase].
@ProviderFor(completeTaskUseCase)
final completeTaskUseCaseProvider =
    AutoDisposeProvider<CompleteTaskUseCase>.internal(
  completeTaskUseCase,
  name: r'completeTaskUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completeTaskUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompleteTaskUseCaseRef = AutoDisposeProviderRef<CompleteTaskUseCase>;
String _$createTaskUseCaseHash() => r'541b8e52a4cc6bc665b12c34c530c312593ec9cc';

/// See also [createTaskUseCase].
@ProviderFor(createTaskUseCase)
final createTaskUseCaseProvider =
    AutoDisposeProvider<CreateTaskUseCase>.internal(
  createTaskUseCase,
  name: r'createTaskUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createTaskUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateTaskUseCaseRef = AutoDisposeProviderRef<CreateTaskUseCase>;
String _$filteredTasksHash() => r'f6afda8f040843191da355b18e1c387c3e6bf5d3';

/// See also [filteredTasks].
@ProviderFor(filteredTasks)
final filteredTasksProvider =
    AutoDisposeProvider<AsyncValue<List<TaskModel>>>.internal(
  filteredTasks,
  name: r'filteredTasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredTasksRef = AutoDisposeProviderRef<AsyncValue<List<TaskModel>>>;
String _$activeCategoriesHash() => r'c152b5dbe3208626d4fb8a48d85ee1f4d4825971';

/// See also [activeCategories].
@ProviderFor(activeCategories)
final activeCategoriesProvider =
    AutoDisposeProvider<AsyncValue<List<String>>>.internal(
  activeCategories,
  name: r'activeCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveCategoriesRef = AutoDisposeProviderRef<AsyncValue<List<String>>>;
String _$todayTasksHash() => r'c7f2ce226d0b5a4635809ea02f5091c0fb11f6b0';

/// See also [todayTasks].
@ProviderFor(todayTasks)
final todayTasksProvider =
    AutoDisposeProvider<AsyncValue<List<TaskModel>>>.internal(
  todayTasks,
  name: r'todayTasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTasksRef = AutoDisposeProviderRef<AsyncValue<List<TaskModel>>>;
String _$taskStatusCountHash() => r'277ecf0d52f88550b413aea62189f2405b5ab9b2';

/// See also [taskStatusCount].
@ProviderFor(taskStatusCount)
final taskStatusCountProvider = AutoDisposeProvider<Map<String, int>>.internal(
  taskStatusCount,
  name: r'taskStatusCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskStatusCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskStatusCountRef = AutoDisposeProviderRef<Map<String, int>>;
String _$taskCategoryFilterHash() =>
    r'cfb2706997f9c31a24af8668e7ca7239d7dff5f0';

/// See also [TaskCategoryFilter].
@ProviderFor(TaskCategoryFilter)
final taskCategoryFilterProvider =
    AutoDisposeNotifierProvider<TaskCategoryFilter, Set<String>>.internal(
  TaskCategoryFilter.new,
  name: r'taskCategoryFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskCategoryFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskCategoryFilter = AutoDisposeNotifier<Set<String>>;
String _$taskSearchQueryHash() => r'25146e733180fee73f9c58890d815c6a6745e363';

/// See also [TaskSearchQuery].
@ProviderFor(TaskSearchQuery)
final taskSearchQueryProvider =
    AutoDisposeNotifierProvider<TaskSearchQuery, String>.internal(
  TaskSearchQuery.new,
  name: r'taskSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskSearchQuery = AutoDisposeNotifier<String>;
String _$taskViewModeHash() => r'e92eb7fd1c438418bbdb57ee7de030dfbb8e627a';

/// See also [TaskViewMode].
@ProviderFor(TaskViewMode)
final taskViewModeProvider =
    AutoDisposeNotifierProvider<TaskViewMode, bool>.internal(
  TaskViewMode.new,
  name: r'taskViewModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskViewModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskViewMode = AutoDisposeNotifier<bool>;
String _$tasksHash() => r'f16789aaf4d8d3c0c22fc6d09da4a192bf0b2565';

/// See also [Tasks].
@ProviderFor(Tasks)
final tasksProvider = AsyncNotifierProvider<Tasks, List<TaskModel>>.internal(
  Tasks.new,
  name: r'tasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Tasks = AsyncNotifier<List<TaskModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
