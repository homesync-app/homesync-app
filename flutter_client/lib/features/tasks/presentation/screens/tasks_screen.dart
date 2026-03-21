import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
// ignore: implementation_imports
import 'package:timeago/src/messages/es_messages.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

import 'package:homesync_client/features/tasks/presentation/widgets/add_task_options_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/edit_task_sheet.dart';
import 'package:homesync_client/shared/widgets/schedule_dialog.dart'
    show ScheduleDialog, TaskRepeatMode;
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/features/tasks/presentation/screens/calendar_screen.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  RealtimeChannel? _tasksChannel;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', EsMessages());
    _tabController = TabController(length: 2, vsync: this);

    // Sync tab controller with provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isCalendar = ref.read(taskViewModeProvider);
      if (isCalendar) _tabController.index = 1;
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          ref.read(taskViewModeProvider.notifier).setList();
        } else {
          ref.read(taskViewModeProvider.notifier).setCalendar();
        }
      }
    });

    _setupRealtime();
  }

  @override
  void dispose() {
    _tasksChannel?.unsubscribe();
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    final nextValue = !_isSearchOpen;
    setState(() => _isSearchOpen = nextValue);
    if (nextValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _searchController.clear();
      ref.read(taskSearchQueryProvider.notifier).setQuery('');
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _setupRealtime() async {
    // Wait for household ID to be available
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null || !mounted) return;

    _tasksChannel = ref
        .read(supabaseClientProvider)
        .channel('tasks_screen:$householdId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'household_id',
            value: householdId,
          ),
          callback: (_) {
            if (mounted) {
              ref.invalidate(tasksProvider);
            }
          },
        )
        .subscribe();
  }

  void _showScheduleDialog(TaskModel task) {
    final members = ref
        .read(householdMembersProvider)
        .maybeWhen(data: (m) => m, orElse: () => <MemberModel>[]);

    showDialog(
      context: context,
      builder: (context) => ScheduleDialog(
        currentRepeat: task.recurrenceType,
        members: members
            .map((m) => {
                  'user_id': m.userId,
                  'users': {'full_name': m.fullName, 'email': m.email},
                })
            .toList(),
        onSave: (mode, customDays, assignedMembers) async {
          String? recurrenceType;
          switch (mode) {
            case TaskRepeatMode.daily:
              recurrenceType = 'daily';
            case TaskRepeatMode.weekly:
              recurrenceType = 'weekly';
            case TaskRepeatMode.monthly:
              recurrenceType = 'monthly';
            case TaskRepeatMode.custom:
              recurrenceType = 'custom';
            case TaskRepeatMode.none:
              recurrenceType = null;
          }
          try {
            await ref
                .read(tasksProvider.notifier)
                .updateSchedule(task, recurrenceType);
            if (mounted) {
              _showSnack('Frecuencia actualizada', AppColors.accentGreen);
            }
          } catch (e) {
            if (mounted) _showSnack('Error: $e', AppColors.error);
          }
        },
      ),
    );
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar tarea?'),
        content: Text('Se eliminara "${task.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(tasksProvider.notifier).deleteTask(task);
      if (mounted) _showSnack('Tarea eliminada', AppColors.accentGreen);
    } catch (e) {
      if (mounted) _showSnack('Error: $e', AppColors.error);
    }
  }

  void _showCreateTaskDialog() async {
    final members = ref
        .read(householdMembersProvider)
        .maybeWhen(data: (m) => m, orElse: () => <MemberModel>[]);

    final result = await AddTaskOptionsSheet.show(context, members);

    if (result == true) {
      // Creation handled by silentRefresh in notifier
    }
  }

  void _showEditDialog(TaskModel task) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTaskSheet(task: task),
    );

    if (result == true) {
      // Updates handled via silentRefresh or state update
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTabShell() {
    return AppSegmentedTabs(
      controller: _tabController,
      labels: const ['Lista', 'Calendario'],
      padding: const EdgeInsets.all(6),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(taskViewModeProvider, (previous, isCalendar) {
      final targetIndex = isCalendar ? 1 : 0;
      if (_tabController.index != targetIndex) {
        _tabController.animateTo(targetIndex);
      }
    });

    final theme = context.theme;
    final filteredAsync = ref.watch(filteredTasksProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final selectedCategories = ref.watch(taskCategoryFilterProvider);
    final activeCatsAsync = ref.watch(activeCategoriesProvider);

    final members = membersAsync.maybeWhen(
      data: (m) => m,
      orElse: () => <MemberModel>[],
    );
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: theme.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: _showCreateTaskDialog,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: theme.border.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          extendedPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(
            'Nueva tarea',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 15),
          ),
        ).animateScaleIn(delay: 400),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: _buildTabShell(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TASK LIST TAB
                filteredAsync.when(
                  loading: () => const AppLoadingState(
                    message: 'Cargando tareas...',
                  ),
                  error: (e, _) => AppErrorState(
                    message: 'No pudimos cargar las tareas.',
                    onRetry: () {
                      ref.invalidate(tasksProvider);
                      ref.invalidate(categoriesProvider);
                    },
                  ),
                  data: (tasks) => RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(tasksProvider);
                      ref.invalidate(categoriesProvider);
                    },
                    color: AppColors.accentGold,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
                            child: activeCatsAsync.when(
                              data: (activeCats) {
                                return categoriesAsync.when(
                                  data: (catList) {
                                    final visibleCats = catList
                                        .where((c) => activeCats.contains(
                                            AppColors.normaliseCategory(c.id)))
                                        .toList();

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 42,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: [
                                              _buildSearchChip()
                                                  .animateStaggered(0),
                                              _buildCategoryChip(
                                                null,
                                                'Todas',
                                                AppColors.textSecondary,
                                              ).animateStaggered(1),
                                              ...visibleCats
                                                  .asMap()
                                                  .entries
                                                  .map(
                                                    (e) => _buildCategoryChip(
                                                      e.value.id,
                                                      e.value.name,
                                                      AppColors.fromHex(
                                                          e.value.color),
                                                    ).animateStaggered(
                                                        e.key + 2),
                                                  ),
                                            ],
                                          ),
                                        ),
                                        AnimatedSize(
                                          duration:
                                              const Duration(milliseconds: 220),
                                          curve: Curves.easeOutCubic,
                                          child: _isSearchOpen
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: theme.surface,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(
                                                        color: theme.border
                                                            .withValues(
                                                                alpha: 0.88),
                                                      ),
                                                      boxShadow:
                                                          theme.cardShadow,
                                                    ),
                                                    child: TextField(
                                                      controller:
                                                          _searchController,
                                                      focusNode:
                                                          _searchFocusNode,
                                                      textInputAction:
                                                          TextInputAction
                                                              .search,
                                                      onChanged: (val) {
                                                        ref
                                                            .read(
                                                                taskSearchQueryProvider
                                                                    .notifier)
                                                            .setQuery(val);
                                                        setState(() {});
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Buscar tarea o rutina',
                                                        hintStyle: TextStyle(
                                                          color:
                                                              theme.textMuted,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.search_rounded,
                                                          color: theme
                                                              .textSecondary,
                                                        ),
                                                        suffixIcon:
                                                            _searchController
                                                                    .text
                                                                    .isNotEmpty
                                                                ? IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      _searchController
                                                                          .clear();
                                                                      ref
                                                                          .read(taskSearchQueryProvider
                                                                              .notifier)
                                                                          .setQuery(
                                                                              '');
                                                                      setState(
                                                                          () {});
                                                                      _searchFocusNode
                                                                          .requestFocus();
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .close_rounded,
                                                                      color: theme
                                                                          .textSecondary,
                                                                    ),
                                                                  )
                                                                : null,
                                                        filled: true,
                                                        fillColor:
                                                            Colors.transparent,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 14,
                                                          horizontal: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ],
                                    );
                                  },
                                  loading: () => const SizedBox(),
                                  error: (_, __) => Row(
                                    children: [
                                      _buildSearchChip(),
                                      _buildCategoryChip(
                                        null,
                                        'Todas',
                                        AppColors.textSecondary,
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loading: () => const SizedBox(),
                              error: (_, __) => const SizedBox(),
                            ),
                          ).animateEntrance(delay: 100),
                        ),
                        // Tasks list
                        SliverPadding(
                          padding: EdgeInsets.only(
                            bottom: ref.read(tasksProvider.notifier).hasMore &&
                                    tasks.isNotEmpty &&
                                    selectedCategories.isEmpty
                                ? 20
                                : 140,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              if (tasks.isEmpty)
                                _buildEmptyState(selectedCategories.isEmpty
                                    ? null
                                    : 'filtered'),
                              ..._buildGroupedTasks(
                                tasks,
                                categoriesAsync.maybeWhen(
                                  data: (list) => list,
                                  orElse: () => [],
                                ),
                                members,
                                selectedCategories,
                              ),
                            ]),
                          ),
                        ),
                        if (ref.read(tasksProvider.notifier).hasMore &&
                            tasks.isNotEmpty &&
                            selectedCategories.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 0, 24, 140),
                              child: Center(
                                child: OutlinedButton.icon(
                                  onPressed: () => ref
                                      .read(tasksProvider.notifier)
                                      .loadMore(),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Cargar mas tareas',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                        color: AppColors.primary, width: 1.5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // CALENDAR TAB
                CalendarScreen(
                  onEdit: (task) => _showEditDialog(task),
                  onSchedule: (task) => _showScheduleDialog(task),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip() {
    final theme = context.theme;
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final isSelected = _isSearchOpen || hasQuery;

    return GestureDetector(
      onTap: _toggleSearch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.12)
              : theme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? theme.primary.withValues(alpha: 0.45)
                : theme.border,
            width: isSelected ? 1.4 : 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : theme.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.close_rounded : Icons.search_rounded,
              size: 18,
              color: isSelected ? theme.primary : theme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              hasQuery ? 'Buscando' : 'Buscar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? theme.primary : theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String? id, String name, Color color) {
    final selectedCategories = ref.watch(taskCategoryFilterProvider);
    final isSelected = id == null
        ? selectedCategories.isEmpty
        : selectedCategories.contains(AppColors.normaliseCategory(id));
    final theme = context.theme;

    return GestureDetector(
      onTap: () {
        if (id == null) {
          ref.read(taskCategoryFilterProvider.notifier).clear();
        } else {
          ref
              .read(taskCategoryFilterProvider.notifier)
              .toggle(AppColors.normaliseCategory(id));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : theme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.45) : theme.border,
            width: isSelected ? 1.4 : 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  )
                ]
              : theme.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppColors.getCategoryMaterialIcon(id ?? name),
              color: isSelected ? color : color.withValues(alpha: 0.85),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected ? color : theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? filterStatus) {
    return AppEmptyState(
      title: filterStatus == null
          ? 'No hay tareas configuradas'
          : 'No hay tareas con esos filtros',
      subtitle: filterStatus == null
          ? 'Agrega tu primera tarea o activa una categoria para empezar a organizar la casa.'
          : 'Proba cambiar la categoria o crear una nueva tarea.',
      icon: filterStatus == null
          ? Icons.edit_note_rounded
          : Icons.filter_list_off_rounded,
    );
  }

  List<Widget> _buildGroupedTasks(
    List<TaskModel> tasks,
    List<CategoryModel> categories,
    List<MemberModel> members,
    Set<String> selectedCategories,
  ) {
    // 1. Group by category
    // Show all persisted tasks so users can always edit/program/delete them.
    final deduped = tasks;

    // 2. Build Category Lookup Map (Key: Normalised ID)
    final catLookup = <String, CategoryModel>{};
    for (final c in categories) {
      final norm = AppColors.normaliseCategory(c.id);
      // If collision, keep existing (usually the first in sort order)
      if (!catLookup.containsKey(norm)) {
        catLookup[norm] = c;
      }
    }

    // Filter if specific categories selected
    List<TaskModel> tasksToDisplay = deduped;
    if (selectedCategories.isNotEmpty) {
      tasksToDisplay = deduped
          .where((t) => selectedCategories
              .contains(AppColors.normaliseCategory(t.category)))
          .toList();
    }

    // 3. Group the tasks to display
    final grouped = <String, List<TaskModel>>{};
    for (final t in tasksToDisplay) {
      final normCat = AppColors.normaliseCategory(t.category);
      (grouped[normCat] ??= []).add(t);
    }

    // 4. Sort categories by sortOrder if available
    final displayCats = grouped.keys.toList();
    displayCats.sort((a, b) {
      final orderA = catLookup[a]?.sortOrder ?? 99;
      final orderB = catLookup[b]?.sortOrder ?? 99;
      return orderA.compareTo(orderB);
    });

    final widgets = <Widget>[];
    for (final normCat in displayCats) {
      final catTasks = grouped[normCat]!;
      final catInfo = catLookup[normCat] ??
          CategoryModel(
              id: normCat,
              name:
                  normCat.substring(0, 1).toUpperCase() + normCat.substring(1),
              icon: 'home',
              color: '#94A3B8');

      widgets.add(_SectionHeader(
        icon: AppColors.getCategoryMaterialIcon(normCat),
        title: catInfo.name,
        count: catTasks.length,
        color: AppColors.fromHex(catInfo.color),
      ).animateEntrance());

      widgets.addAll(catTasks.asMap().entries.map((entry) {
        final index = entry.key;
        final task = entry.value;
        return _TaskCard(
          key: ValueKey(task.id),
          task: task,
          onSchedule: () => _showScheduleDialog(task),
          onEdit: () => _showEditDialog(task),
          onDelete: () => _deleteTask(task),
        ).animateStaggered(index);
      }));
    }

    return widgets;
  }
}

// Section Header

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color? color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.primary;
    final theme = context.theme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 16,
              color: themeColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary.withValues(alpha: 0.82),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// TaskModel Card (now typed with TaskModel model)

class _TaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback onSchedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    super.key,
    required this.task,
    required this.onSchedule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = context.theme;

    // Resolve dynamic category data
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryData = categoriesAsync.maybeWhen(
      data: (list) {
        try {
          return list.firstWhere((c) => c.id == task.category);
        } catch (_) {
          return null;
        }
      },
      orElse: () => null,
    );

    final categoryColor = categoryData != null
        ? AppColors.fromHex(categoryData.color)
        : AppColors.getCategoryColor(task.category);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _isExpanded ? theme.modalShadow : theme.cardShadow,
        border: Border.all(
          color: _isExpanded
              ? categoryColor.withValues(alpha: 0.3)
              : (task.isOverdue
                  ? AppColors.accentRed.withValues(alpha: 0.3)
                  : theme.border.withValues(alpha: 0.9)),
          width: _isExpanded ? 1.5 : 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _isExpanded = !_isExpanded);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: theme.textPrimary,
                            letterSpacing: -0.35,
                            height: 1.12,
                          ),
                        ),
                      ),
                      if (!_isExpanded && task.xpReward > 0) ...[
                        const SizedBox(width: 10),
                        _badge('XP ${task.xpReward}', AppColors.accentGold),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _pill(
                              icon: task.isRecurring
                                  ? Icons.event_repeat_rounded
                                  : Icons.edit_calendar_rounded,
                              label: task.isRecurring
                                  ? task.recurrenceLabel
                                  : 'Sin programar',
                              color: task.isRecurring
                                  ? AppColors.primary
                                  : AppColors.accentPeach,
                              background: task.isRecurring
                                  ? AppColors.primary.withValues(alpha: 0.16)
                                  : AppColors.accentPeach
                                      .withValues(alpha: 0.18),
                            ),
                            if (task.isOverdue)
                              _pill(
                                icon: Icons.priority_high_rounded,
                                label: 'Vencida',
                                color: AppColors.accentRed,
                                background:
                                    AppColors.accentRed.withValues(alpha: 0.16),
                              ),
                          ],
                        ),
                      ),
                      if (!_isExpanded && task.coinReward > 0) ...[
                        const SizedBox(width: 10),
                        _badge(
                            'Coins ${task.coinReward}', AppColors.accentGreen),
                      ],
                    ],
                  ),
                ],
              ),
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  heightFactor: _isExpanded ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionTilePremium(
                                icon: Icons.edit_rounded,
                                label: 'Editar',
                                color: AppColors.accentGold,
                                onTap: widget.onEdit,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionTilePremium(
                                icon: Icons.schedule_rounded,
                                label: 'Programar',
                                color: AppColors.primary,
                                onTap: widget.onSchedule,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionTilePremium(
                                icon: Icons.delete_outline_rounded,
                                label: 'Eliminar',
                                color: AppColors.accentRed,
                                onTap: widget.onDelete,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTilePremium({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        setState(() => _isExpanded = false);
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color color,
    required Color background,
  }) {
    final readableColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.18),
      color,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: readableColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 10,
              color: readableColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          color: color,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}
