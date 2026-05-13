// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getTasksUseCase)
final getTasksUseCaseProvider = GetTasksUseCaseProvider._();

final class GetTasksUseCaseProvider extends $FunctionalProvider<GetTasksUseCase,
    GetTasksUseCase, GetTasksUseCase> with $Provider<GetTasksUseCase> {
  GetTasksUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getTasksUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getTasksUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetTasksUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetTasksUseCase create(Ref ref) {
    return getTasksUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetTasksUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetTasksUseCase>(value),
    );
  }
}

String _$getTasksUseCaseHash() => r'037c85270e9450e2d214d653005f0610163580b9';

@ProviderFor(completeTaskUseCase)
final completeTaskUseCaseProvider = CompleteTaskUseCaseProvider._();

final class CompleteTaskUseCaseProvider extends $FunctionalProvider<
    CompleteTaskUseCase,
    CompleteTaskUseCase,
    CompleteTaskUseCase> with $Provider<CompleteTaskUseCase> {
  CompleteTaskUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'completeTaskUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$completeTaskUseCaseHash();

  @$internal
  @override
  $ProviderElement<CompleteTaskUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CompleteTaskUseCase create(Ref ref) {
    return completeTaskUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompleteTaskUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompleteTaskUseCase>(value),
    );
  }
}

String _$completeTaskUseCaseHash() =>
    r'40f8a0f3a07a70d57b3be3d5cb3515946464dfc3';

@ProviderFor(createTaskUseCase)
final createTaskUseCaseProvider = CreateTaskUseCaseProvider._();

final class CreateTaskUseCaseProvider extends $FunctionalProvider<
    CreateTaskUseCase,
    CreateTaskUseCase,
    CreateTaskUseCase> with $Provider<CreateTaskUseCase> {
  CreateTaskUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createTaskUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createTaskUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateTaskUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateTaskUseCase create(Ref ref) {
    return createTaskUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateTaskUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateTaskUseCase>(value),
    );
  }
}

String _$createTaskUseCaseHash() => r'30da0aa1ce95a757cc504b8de1932976d085c5bd';

@ProviderFor(TaskCategoryFilter)
final taskCategoryFilterProvider = TaskCategoryFilterProvider._();

final class TaskCategoryFilterProvider
    extends $NotifierProvider<TaskCategoryFilter, Set<String>> {
  TaskCategoryFilterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'taskCategoryFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskCategoryFilterHash();

  @$internal
  @override
  TaskCategoryFilter create() => TaskCategoryFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$taskCategoryFilterHash() =>
    r'cfb2706997f9c31a24af8668e7ca7239d7dff5f0';

abstract class _$TaskCategoryFilter extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Set<String>, Set<String>>, Set<String>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TaskSearchQuery)
final taskSearchQueryProvider = TaskSearchQueryProvider._();

final class TaskSearchQueryProvider
    extends $NotifierProvider<TaskSearchQuery, String> {
  TaskSearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'taskSearchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskSearchQueryHash();

  @$internal
  @override
  TaskSearchQuery create() => TaskSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$taskSearchQueryHash() => r'25146e733180fee73f9c58890d815c6a6745e363';

abstract class _$TaskSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TaskViewMode)
final taskViewModeProvider = TaskViewModeProvider._();

final class TaskViewModeProvider extends $NotifierProvider<TaskViewMode, bool> {
  TaskViewModeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'taskViewModeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskViewModeHash();

  @$internal
  @override
  TaskViewMode create() => TaskViewMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$taskViewModeHash() => r'e92eb7fd1c438418bbdb57ee7de030dfbb8e627a';

abstract class _$TaskViewMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(Tasks)
final tasksProvider = TasksProvider._();

final class TasksProvider
    extends $AsyncNotifierProvider<Tasks, List<TaskModel>> {
  TasksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tasksProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tasksHash();

  @$internal
  @override
  Tasks create() => Tasks();
}

String _$tasksHash() => r'aa053c123b5a4f4cae9000195d8a7587a6c396ee';

abstract class _$Tasks extends $AsyncNotifier<List<TaskModel>> {
  FutureOr<List<TaskModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TaskModel>>, List<TaskModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<TaskModel>>, List<TaskModel>>,
        AsyncValue<List<TaskModel>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredTasks)
final filteredTasksProvider = FilteredTasksProvider._();

final class FilteredTasksProvider extends $FunctionalProvider<
    AsyncValue<List<TaskModel>>,
    AsyncValue<List<TaskModel>>,
    AsyncValue<List<TaskModel>>> with $Provider<AsyncValue<List<TaskModel>>> {
  FilteredTasksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredTasksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredTasksHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<TaskModel>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<List<TaskModel>> create(Ref ref) {
    return filteredTasks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<TaskModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<TaskModel>>>(value),
    );
  }
}

String _$filteredTasksHash() => r'07b0cf2cbbd5dd576513fdb45d7f8846d5c1daaf';

@ProviderFor(activeCategories)
final activeCategoriesProvider = ActiveCategoriesProvider._();

final class ActiveCategoriesProvider extends $FunctionalProvider<
    AsyncValue<List<String>>,
    AsyncValue<List<String>>,
    AsyncValue<List<String>>> with $Provider<AsyncValue<List<String>>> {
  ActiveCategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeCategoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeCategoriesHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<String>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<List<String>> create(Ref ref) {
    return activeCategories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<String>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<String>>>(value),
    );
  }
}

String _$activeCategoriesHash() => r'f3e787e90242b435c321b007d360e32f89a6b3b3';

@ProviderFor(todayTasks)
final todayTasksProvider = TodayTasksProvider._();

final class TodayTasksProvider extends $FunctionalProvider<
    AsyncValue<List<TaskModel>>,
    AsyncValue<List<TaskModel>>,
    AsyncValue<List<TaskModel>>> with $Provider<AsyncValue<List<TaskModel>>> {
  TodayTasksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todayTasksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todayTasksHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<TaskModel>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<List<TaskModel>> create(Ref ref) {
    return todayTasks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<TaskModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<TaskModel>>>(value),
    );
  }
}

String _$todayTasksHash() => r'23031010ef8c857fc946cc5f0bd4e701d2bde1d2';

@ProviderFor(taskStatusCount)
final taskStatusCountProvider = TaskStatusCountProvider._();

final class TaskStatusCountProvider extends $FunctionalProvider<
    Map<String, int>,
    Map<String, int>,
    Map<String, int>> with $Provider<Map<String, int>> {
  TaskStatusCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'taskStatusCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskStatusCountHash();

  @$internal
  @override
  $ProviderElement<Map<String, int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, int> create(Ref ref) {
    return taskStatusCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int>>(value),
    );
  }
}

String _$taskStatusCountHash() => r'9cfc50c69666276489a030071efc7a475363355c';
