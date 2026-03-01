import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
// ignore: implementation_imports
import 'package:timeago/src/messages/es_messages.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_providers.dart';

import 'package:homesync_client/shared/widgets/add_task_options_sheet.dart';
import 'package:homesync_client/shared/widgets/edit_task_sheet.dart';
import 'package:homesync_client/shared/widgets/schedule_dialog.dart' show ScheduleDialog, TaskRepeatMode;
import 'package:homesync_client/features/tasks/presentation/screens/calendar_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TasksScreen — Riverpod + Realtime
// ─────────────────────────────────────────────────────────────────────────────

class TasksScreen extends ConsumerStatefulWidget {
  final SupabaseAuthService auth;
  final SupabaseRpcService rpc;

  const TasksScreen({super.key, required this.auth, required this.rpc});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  RealtimeChannel? _tasksChannel;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', EsMessages());
    _setupRealtime();
  }

  @override
  void dispose() {
    _tasksChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _setupRealtime() async {
    // Wait for household ID to be available
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null || !mounted) return;

    _tasksChannel = Supabase.instance.client
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

  // ── Actions ────────────────────────────────────────────────────────────────

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
              _showSnack('Frecuencia actualizada ✓', AppColors.accentGreen);
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
        title: const Text('¿Eliminar tarea?'),
        content: Text('Se eliminará "${task.title}"'),
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
      ref.invalidate(tasksProvider);
    }
  }

  void _showEditDialog(TaskModel task) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTaskSheet(task : task),
    );

    if (result == true) {
      ref.invalidate(tasksProvider);
    }
  }

  Future<void> _completeTask(TaskModel task) async {
    try {
      final result = await ref.read(tasksProvider.notifier).completeTask(task);
      if (mounted) {
        final data = result['data'] ?? result;
        final xp = data['xp_earned'] ?? task.xpReward;
        final coins = data['coins_earned'] ?? task.coinReward;
        _showSnack(
          '⭐ ¡Ganaste $xp XP y $coins coins!',
          AppColors.accentTeal,
        );
      }
    } catch (e) {
      if (mounted) _showSnack('Error al completar: $e', AppColors.error);
    }
  }

  Future<void> _verifyTask(TaskModel task) async {
    try {
      await ref.read(tasksProvider.notifier).verifyTask(task);
      if (mounted) _showSnack('Tarea verificada ✓', AppColors.accentGreen);
    } catch (e) {
      if (mounted) _showSnack('Error: $e', AppColors.error);
    }
  }

  Future<void> _objectTask(TaskModel task) async {
    try {
      await ref.read(tasksProvider.notifier).objectTask(task);
      if (mounted) _showSnack('Tarea objetada', AppColors.warning);
    } catch (e) {
      if (mounted) _showSnack('Error: $e', AppColors.error);
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredTasksProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final selectedCategory = ref.watch(taskCategoryFilterProvider);
    final isCalendarMode = ref.watch(taskViewModeProvider);
    final currentUserId = ref.read(currentUserIdProvider);

    final members = membersAsync.maybeWhen(
      data: (m) => m,
      orElse: () => <MemberModel>[],
    );



    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          heroTag: null,
          onPressed: _showCreateTaskDialog,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Nueva tarea',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── View mode toggle ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeToggleButton(
                      'Lista',
                      Icons.format_list_bulleted_rounded,
                      !isCalendarMode,
                      () => ref.read(taskViewModeProvider.notifier).setList(),
                    ),
                  ),
                  Expanded(
                    child: _buildModeToggleButton(
                      'Calendario',
                      Icons.calendar_month_rounded,
                      isCalendarMode,
                      () => ref.read(taskViewModeProvider.notifier).setCalendar(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: isCalendarMode
                ? const CalendarScreen()
                : filteredAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          const Text('Error al cargar tareas',
                              style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(tasksProvider),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
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
                          // Search bar
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                              child: Consumer(
                                builder: (context, ref, _) {
                                  return TextField(
                                    onChanged: (val) => ref.read(taskSearchQueryProvider.notifier).setQuery(val),
                                    decoration: InputDecoration(
                                      hintText: 'Buscar tarea...',
                                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Category chips — only show cats that have tasks
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 8),
                              child: SizedBox(
                                height: 50,
                                child: categoriesAsync.when(
                                  data: (catList) {
                                    // Which normalised cats have tasks?
                                    final activeCats = tasks
                                        .map((t) => AppColors.normaliseCategory(t.category))
                                        .toSet();
                                    // Filter DB categories to only those with tasks,
                                    // preserving sort_order from DB
                                    final visibleCats = catList
                                        .where((c) => activeCats.contains(
                                              AppColors.normaliseCategory(c.id)))
                                        .toList();
                                    return ListView(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      children: [
                                        _buildCategoryChip(
                                            null, 'Todas', '📋', AppColors.textSecondary),
                                        ...visibleCats.map((c) => _buildCategoryChip(
                                              c.id,
                                              c.name,
                                              c.icon,
                                              AppColors.fromHex(c.color),
                                            )),
                                      ],
                                    );
                                  },
                                  loading: () => const SizedBox(),
                                  error: (_, __) => ListView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    children: [
                                      _buildCategoryChip(
                                          null, 'Todas', '📋', AppColors.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Tasks list
                          SliverPadding(
                            padding: const EdgeInsets.only(bottom: 140),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                if (tasks.isEmpty)
                                  _buildEmptyState(selectedCategory),
                                ..._buildGroupedTasks(
                                  tasks,
                                  categoriesAsync.maybeWhen(
                                    data: (list) => list.map((c) => {'id': c.id, 'name': c.name, 'icon': c.icon}).toList(),
                                    orElse: () => [],
                                  ),
                                  members,
                                  currentUserId,
                                  selectedCategory,
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );

  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildModeToggleButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String? id, String name, String icon, Color color) {
    final selectedCategory = ref.watch(taskCategoryFilterProvider);
    final isSelected = selectedCategory == id;

    return GestureDetector(
      onTap: () => ref.read(taskCategoryFilterProvider.notifier).select(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.cardLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFF1F5F9),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppColors.getCategoryMaterialIcon(name),
              color: isSelected ? color : color.withValues(alpha: 0.8),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyState(String? selectedCategory) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              selectedCategory == null 
                  ? Icons.task_alt_rounded 
                  : Icons.filter_list_off_rounded,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            selectedCategory == null
                ? '¡Todo despejado!'
                : 'No hay tareas aquí',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            selectedCategory == null
                ? 'Relájate, no tienes tareas pendientes por ahora.'
                : 'Prueba a cambiar de categoría o crea una nueva.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedTasks(
    List<TaskModel> tasks,
    List<Map<String, String>> categories,
    List<MemberModel> members,
    String? currentUserId,
    String? selectedCategory,
  ) {
    // Deduplicate by title+normalised-category
    final uniqueMap = <String, TaskModel>{};
    for (final t in tasks) {
      final normCat = AppColors.normaliseCategory(t.category);
      final key = '${t.title.toLowerCase().trim()}_$normCat';
      final existing = uniqueMap[key];
      if (existing == null || t.xpReward > existing.xpReward) {
        uniqueMap[key] = t;
      }
    }
    final deduped = uniqueMap.values.toList();

    if (selectedCategory != null) {
      final normSel = AppColors.normaliseCategory(selectedCategory);
      final info = categories.firstWhere(
        (c) => AppColors.normaliseCategory(c['id']) == normSel,
        orElse: () => {'id': normSel, 'icon': '🏠', 'name': normSel},
      );
      return [
        _SectionHeader(
          icon: info['icon']!,
          title: info['name']!,
          count: deduped.length,
        ),
        ...deduped.map((t) => _TaskCard(
              task : t,
              members: members,
              currentUserId: currentUserId,
              onSchedule: () => _showScheduleDialog(t),
              onEdit: () => _showEditDialog(t),
              onDelete: () => _deleteTask(t),
              onComplete: () => _completeTask(t),
              onVerify: () => _verifyTask(t),
              onObject: () => _objectTask(t),
            )),
      ];
    }

    // Group by normalised category
    final grouped = <String, List<TaskModel>>{};
    for (final t in deduped) {
      final normCat = AppColors.normaliseCategory(t.category);
      (grouped[normCat] ??= []).add(t);
    }

    // Build a display map from DB categories (normalised) for label/icon lookup
    final catDisplayMap = <String, Map<String, String>>{};
    for (final c in categories) {
      catDisplayMap[AppColors.normaliseCategory(c['id'])] = c;
    }
    // Also add any grouped cats not in the DB list
    for (final normCat in grouped.keys) {
      if (!catDisplayMap.containsKey(normCat)) {
        catDisplayMap[normCat] = {'id': normCat, 'icon': '📦', 'name': normCat};
      }
    }

    final widgets = <Widget>[];
    // Preserve the sort order from DB categories first, then extras
    final orderedCats = [
      ...categories.map((c) => AppColors.normaliseCategory(c['id'])).where((n) => grouped.containsKey(n)),
      ...grouped.keys.where((n) => !categories.any((c) => AppColors.normaliseCategory(c['id']) == n)),
    ];

    for (final normCat in orderedCats) {
      final catTasks = grouped[normCat];
      if (catTasks != null && catTasks.isNotEmpty) {
        final info = catDisplayMap[normCat] ?? {'id': normCat, 'icon': '📦', 'name': normCat};
        widgets.add(_SectionHeader(
          icon: info['icon']!,
          title: info['name']!,
          count: catTasks.length,
        ));
        widgets.addAll(catTasks.map((t) => _TaskCard(
              task : t,
              members: members,
              currentUserId: currentUserId,
              onSchedule: () => _showScheduleDialog(t),
              onEdit: () => _showEditDialog(t),
              onDelete: () => _deleteTask(t),
              onComplete: () => _completeTask(t),
              onVerify: () => _verifyTask(t),
              onObject: () => _objectTask(t),
            )));
      }
    }
    return widgets;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String icon;
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  AppColors.getCategoryMaterialIcon(title),
                  size: 16,
                  color: color ?? AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: color ?? AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '$count ${count == 1 ? 'tarea' : 'tareas'}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TaskModel Card (now typed with TaskModel model)
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final String? currentUserId;
  final List<MemberModel> members;
  final VoidCallback onSchedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onComplete;
  final VoidCallback onVerify;
  final VoidCallback onObject;

  const _TaskCard({
    required this.task,
    required this.currentUserId,
    required this.members,
    required this.onSchedule,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
    required this.onVerify,
    required this.onObject,
  });

  @override
  ConsumerState<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard> {
  bool _isExpanded = false;

  String _getTimeAgoLabel() {
    final task = widget.task;
    if (task.lastCompletedAt == null) return 'Nunca completada';
    final date = DateTime.tryParse(task.lastCompletedAt!) ?? DateTime.now();
    return 'Hace ${timeago.format(date, locale: 'es_short')}';
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isExpanded ? 0.08 : 0.04),
            blurRadius: _isExpanded ? 20 : 15,
            offset: Offset(0, _isExpanded ? 10 : 8),
          ),
        ],
        border: Border.all(
          color: _isExpanded 
              ? categoryColor.withValues(alpha: 0.3)
              : (task.isOverdue ? AppColors.accentRed.withValues(alpha: 0.3) : const Color(0xFFF1F5F9)),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _isExpanded = !_isExpanded);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (task.isOverdue) ...[
                              _badge('Vencida', AppColors.accentRed),
                              const SizedBox(width: 8),
                            ],
                            if (task.lastCompletedAt != null) ...[
                              _buildLastCompletedAvatar(widget.members, task.completedBy),
                              const SizedBox(width: 8),
                            ],
                            const Icon(Icons.history_rounded,
                                size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeAgoLabel(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Reward badges (fade out when expanded maybe? no, keep it simple)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isExpanded ? 0.0 : 1.0,
                    child: Visibility(
                      visible: !_isExpanded,
                      child: _buildRewardBadges(task),
                    ),
                  ),
                ],
              ),
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  alignment: Alignment.topCenter,
                  heightFactor: _isExpanded ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionTilePremium(
                              icon: Icons.edit_rounded,
                              label: 'Editar',
                              color: AppColors.accentGold,
                              onTap: widget.onEdit,
                            ),
                            _buildActionTilePremium(
                              icon: Icons.calendar_month_rounded,
                              label: 'Calendario',
                              color: AppColors.primary,
                              onTap: widget.onSchedule,
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.35,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }

  Widget _buildRewardBadges(TaskModel task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (task.xpReward > 0)
          _badge('⭐ ${task.xpReward} XP', AppColors.accentGold),
        if (task.coinReward > 0) ...[
          const SizedBox(height: 4),
          _badge('🪙 ${task.coinReward}', AppColors.accentGreen),
        ],
      ],
    );
  }

  Widget _buildLastCompletedAvatar(List<MemberModel> members, String? userId) {
    if (userId == null) return const SizedBox.shrink();
    
    final member = members.firstWhere(
      (m) => m.userId == userId,
      orElse: () => members.firstWhere(
        (m) => m.id == userId,
        orElse: () => MemberModel(
          id: '',
          userId: userId,
          householdId: '',
          role: 'member',
          joinedAt: DateTime.now(),
          fullName: 'Usuario',
        ),
      ),
    );

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          member.initial,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
