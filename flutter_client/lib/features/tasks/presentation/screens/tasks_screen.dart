import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/screens/calendar_screen.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/add_task_options_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/edit_task_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_floating_action_button.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/schedule_dialog.dart'
    show ScheduleDialog, TaskRepeatMode;
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: implementation_imports
import 'package:timeago/src/messages/es_messages.dart';
import 'package:timeago/timeago.dart' as timeago;

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  RealtimeChannel? _tasksChannel;
  late TabController _tabController;
  late final ConfettiController _completionConfettiController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', EsMessages());
    _tabController = TabController(length: 2, vsync: this);
    _completionConfettiController =
        ConfettiController(duration: const Duration(milliseconds: 1400));

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
    _completionConfettiController.dispose();
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.88,
        child: ScheduleDialog(
          currentRepeat: task.recurrenceType,
          currentWeekdays: task.recurrenceWeekdays,
          currentMonthDays: task.recurrenceMonthDays,
          currentInterval: task.recurrenceInterval,
          currentAssignedTo: task.assignedTo,
          members: members
              .map(
                (m) => {
                  'user_id': m.userId,
                  'users': {
                    'full_name': m.fullName,
                    'email': m.email,
                    'avatar_url': m.avatarUrl,
                  },
                },
              )
              .toList(),
          onSave: (selection) async {
            String? recurrenceType;
            switch (selection.mode) {
              case TaskRepeatMode.daily:
                recurrenceType = 'daily';
                break;
              case TaskRepeatMode.weekly:
                recurrenceType = 'weekly';
                break;
              case TaskRepeatMode.monthly:
                recurrenceType = 'monthly';
                break;
              case TaskRepeatMode.custom:
                recurrenceType = 'custom';
                break;
              case TaskRepeatMode.none:
                recurrenceType = null;
                break;
            }
            final t = AppLocalizations.of(context);
            try {
              await ref.read(tasksProvider.notifier).updateSchedule(
                    task,
                    recurrenceType,
                    recurrenceInterval: selection.recurrenceInterval,
                    recurrenceWeekdays: selection.recurrenceWeekdays,
                    recurrenceMonthDays: selection.recurrenceMonthDays,
                    assignedTo: selection.assignedTo,
                  );
              ref.invalidate(todayTasksProvider);
              if (mounted) {
                _showSnack(
                  t.tasksSnackFrequencyUpdated,
                  AppSnackBarType.success,
                  duration: const Duration(milliseconds: 1400),
                );
              }
            } catch (e) {
              if (mounted) {
                _showSnack(
                  t.commonErrorWithDetails(e.toString()),
                  AppSnackBarType.error,
                );
              }
            }
          },
        ),
      ),
    );
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

  void _showSnack(
    String message,
    AppSnackBarType type, {
    Duration? duration,
  }) {
    AppSnackBar.show(
      context,
      message: message,
      type: type,
      duration: duration,
    );
  }

  Widget _buildTabShell() {
    return AppSegmentedTabs(
      controller: _tabController,
      labels: [
        AppLocalizations.of(context).tasksTabList,
        AppLocalizations.of(context).tasksTabCalendar,
      ],
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
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;
    // Children cannot create tasks; teens and adults can.
    final canCreateTasks = !(currentMember?.isChild ?? false);

    return Scaffold(
      backgroundColor: theme.background,
      floatingActionButton: !canCreateTasks
          ? null
          : AppFloatingActionButton(
              label: AppLocalizations.of(context).tasksFabNew,
              icon: Icons.add_rounded,
              onPressed: _showCreateTaskDialog,
              heroTag: 'tasks_fab',
              margin: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 10,
              ),
              animateIn: true,
            ),
      body: Stack(
        children: [
          Column(
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
                      loading: () => AppLoadingState(
                        message:
                            AppLocalizations.of(context).tasksLoadingMessage,
                      ),
                      error: (e, _) => AppErrorState(
                        message: AppLocalizations.of(context).tasksLoadError,
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
                                padding:
                                    const EdgeInsets.fromLTRB(24, 8, 24, 10),
                                child: activeCatsAsync.when(
                                  data: (activeCats) {
                                    return categoriesAsync.when(
                                      data: (catList) {
                                        final visibleCats = catList
                                            .where(
                                              (c) => activeCats.contains(
                                                CategoryMapping
                                                    .normaliseCategory(
                                                  c.id,
                                                ),
                                              ),
                                            )
                                            .toList();

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ShaderMask(
                                              shaderCallback: (bounds) {
                                                return const LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.white,
                                                    Colors.white,
                                                    Colors.transparent,
                                                  ],
                                                  stops: [0, 0.92, 1],
                                                ).createShader(bounds);
                                              },
                                              blendMode: BlendMode.dstIn,
                                              child: SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 18,
                                                  ),
                                                  itemCount:
                                                      visibleCats.length + 2,
                                                  itemBuilder:
                                                      (context, index) {
                                                    if (index == 0) {
                                                      return _buildSearchChip()
                                                          .animateStaggered(0);
                                                    }

                                                    if (index == 1) {
                                                      return _buildCategoryChip(
                                                        null,
                                                        AppLocalizations.of(
                                                          context,
                                                        ).tasksFilterAll,
                                                        AppColors.textSecondary,
                                                      ).animateStaggered(1);
                                                    }

                                                    final category =
                                                        visibleCats[index - 2];
                                                    return _buildCategoryChip(
                                                      category.id,
                                                      localizedTaskCategoryName(
                                                        AppLocalizations.of(
                                                          context,
                                                        ),
                                                        category,
                                                      ),
                                                      AppColors.fromHex(
                                                        category.color,
                                                      ),
                                                    ).animateStaggered(index);
                                                  },
                                                ),
                                              ),
                                            ),
                                            AnimatedSize(
                                              duration: const Duration(
                                                milliseconds: 220,
                                              ),
                                              curve: Curves.easeOutCubic,
                                              child: _isSearchOpen
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 10,
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: theme.surface,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            20,
                                                          ),
                                                          border: Border.all(
                                                            color: theme.border
                                                                .withValues(
                                                              alpha: 0.88,
                                                            ),
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
                                                                      .notifier,
                                                                )
                                                                .setQuery(val);
                                                            setState(() {});
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                AppLocalizations
                                                                    .of(
                                                              context,
                                                            ).tasksSearchHint,
                                                            hintStyle:
                                                                TextStyle(
                                                              color: theme
                                                                  .textMuted,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            prefixIcon: Icon(
                                                              Icons
                                                                  .search_rounded,
                                                              color: theme
                                                                  .textSecondary,
                                                            ),
                                                            suffixIcon:
                                                                _searchController
                                                                        .text
                                                                        .isNotEmpty
                                                                    ? IconButton(
                                                                        tooltip:
                                                                            AppLocalizations.of(
                                                                          context,
                                                                        ).tasksSearchClearTooltip,
                                                                        onPressed:
                                                                            () {
                                                                          _searchController
                                                                              .clear();
                                                                          ref
                                                                              .read(
                                                                                taskSearchQueryProvider.notifier,
                                                                              )
                                                                              .setQuery(
                                                                                '',
                                                                              );
                                                                          setState(
                                                                            () {},
                                                                          );
                                                                          _searchFocusNode
                                                                              .requestFocus();
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .close_rounded,
                                                                          color:
                                                                              theme.textSecondary,
                                                                        ),
                                                                      )
                                                                    : null,
                                                            filled: true,
                                                            fillColor: Colors
                                                                .transparent,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                20,
                                                              ),
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
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
                                            AppLocalizations.of(context)
                                                .tasksFilterAll,
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
                                bottom: 158 +
                                    MediaQuery.viewPaddingOf(context).bottom,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  if (tasks.isEmpty)
                                    _buildEmptyState(
                                      selectedCategories.isEmpty
                                          ? null
                                          : 'filtered',
                                    ),
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
                                      label: Text(
                                        AppLocalizations.of(context)
                                            .tasksLoadMore,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
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
          Align(
            alignment: Alignment.topCenter,
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _completionConfettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.success,
                  AppColors.primary,
                  Color(0xFFFFE4D5),
                ],
                emissionFrequency: 0.018,
                maxBlastForce: 3.2,
                minBlastForce: 1.0,
                numberOfParticles: 10,
                gravity: 0.18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionCelebration() {
    _completionConfettiController.play();
    HapticFeedback.mediumImpact();
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
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.12)
              : theme.surface,
          borderRadius: BorderRadius.circular(16),
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
              hasQuery
                  ? AppLocalizations.of(context).tasksSearchActiveLabel
                  : AppLocalizations.of(context).tasksSearchIdleLabel,
              maxLines: 1,
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
        : selectedCategories.contains(CategoryMapping.normaliseCategory(id));
    final theme = context.theme;

    return GestureDetector(
      onTap: () {
        if (id == null) {
          ref.read(taskCategoryFilterProvider.notifier).clear();
        } else {
          ref
              .read(taskCategoryFilterProvider.notifier)
              .toggle(CategoryMapping.normaliseCategory(id));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : theme.surface,
          borderRadius: BorderRadius.circular(16),
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
                  ),
                ]
              : theme.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CategoryMapping.getCategoryMaterialIcon(id ?? name),
              color: isSelected ? color : color.withValues(alpha: 0.85),
              size: 18,
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 116),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  color: isSelected ? color : theme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String? filterStatus) {
    final isSolo =
        ref.watch(currentHouseholdProvider).value?.householdType == 'solo';
    final t = AppLocalizations.of(context);
    return AppEmptyState(
      title:
          filterStatus == null ? t.tasksEmptyTitle : t.tasksEmptyFilteredTitle,
      subtitle: filterStatus == null
          ? (isSolo ? t.tasksEmptySoloSubtitle : t.tasksEmptySharedSubtitle)
          : t.tasksEmptyFilteredSubtitle,
      icon: filterStatus == null
          ? Icons.edit_note_rounded
          : Icons.filter_list_off_rounded,
      emoji: filterStatus == null ? '📝' : '🔎',
    );
  }

  List<Widget> _buildGroupedTasks(
    List<TaskModel> tasks,
    List<CategoryModel> categories,
    List<MemberModel> members,
    Set<String> selectedCategories,
  ) {
    // 1. Deduplicate by id (defensive: RPC may return duplicate rows)
    // then group by category so users can always edit/program/delete them.
    final caps = ref.watch(householdCapabilitiesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final hideReviewQueue =
        caps.type == HouseholdType.family && (currentMember?.isAdult ?? false);
    final seen = <String>{};
    final deduped = tasks
        .where((t) => seen.add(t.id))
        .where((t) => !(hideReviewQueue && t.isPendingApproval))
        .toList();

    // 2. Build Category Lookup Map (Key: Normalised ID)
    final catLookup = <String, CategoryModel>{};
    for (final c in categories) {
      final norm = CategoryMapping.normaliseCategory(c.id);
      // If collision, keep existing (usually the first in sort order)
      if (!catLookup.containsKey(norm)) {
        catLookup[norm] = c;
      }
    }

    // Filter if specific categories selected
    List<TaskModel> tasksToDisplay = deduped;
    if (selectedCategories.isNotEmpty) {
      tasksToDisplay = deduped
          .where(
            (t) => selectedCategories
                .contains(CategoryMapping.normaliseCategory(t.category)),
          )
          .toList();
    }

    // 3. Group the tasks to display
    final grouped = <String, List<TaskModel>>{};
    for (final t in tasksToDisplay) {
      final normCat = CategoryMapping.normaliseCategory(t.category);
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
            name: normCat.substring(0, 1).toUpperCase() + normCat.substring(1),
            icon: 'home',
            color: '#94A3B8',
          );

      widgets.add(
        _SectionHeader(
          icon: CategoryMapping.getCategoryMaterialIcon(normCat),
          title: localizedTaskCategoryName(
            AppLocalizations.of(context),
            catInfo,
          ),
          count: catTasks.length,
          color: AppColors.fromHex(catInfo.color),
        ).animateEntrance(),
      );

      widgets.addAll(
        catTasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          return _TaskCard(
            key: ValueKey(task.id),
            task: task,
            onSchedule: () => _showScheduleDialog(task),
            onEdit: () => _showEditDialog(task),
            onCompletedFeedback: _showCompletionCelebration,
          ).animateStaggered(index);
        }),
      );
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
  final VoidCallback onCompletedFeedback;

  const _TaskCard({
    super.key,
    required this.task,
    required this.onSchedule,
    required this.onEdit,
    required this.onCompletedFeedback,
  });

  @override
  ConsumerState<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard> {
  bool _isExpanded = false;
  bool _isSubmitting = false;

  String _recurrenceLabel(AppLocalizations t, String? recurrenceType) {
    switch (recurrenceType) {
      case 'daily':
        return t.createTaskRecurrenceDaily;
      case 'weekly':
        return t.createTaskRecurrenceWeekly;
      case 'monthly':
        return t.createTaskRecurrenceMonthly;
      case 'custom':
        return t.createTaskRecurrenceCustom;
      default:
        return t.createTaskRecurrenceNone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);
    final members =
        ref.watch(householdMembersProvider).value ?? const <MemberModel>[];
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final assignedMember =
        members.where((member) => member.userId == task.assignedTo).firstOrNull;
    final isFamilyMode = caps.type == HouseholdType.family;
    // Approval actions are a premium feature (Modo Padres).
    // We gate on parentModeAvailableProvider (family + premium + adult) so
    // non-premium users and children never see approve/reject buttons.
    // Default to false while members are still loading — never grant adult
    // permissions to an unknown viewer.
    final parentModeActive = ref.watch(parentModeAvailableProvider);
    final isAdultView = isFamilyMode &&
        parentModeActive &&
        (currentMember?.canApprove ?? false);
    // Teens and children must send completions through the adult review
    // queue, but only if the household has approvals enabled. Mirrors the SQL
    // logic in public.should_require_task_approval so the dialog matches what
    // the server will actually do.
    final approvalMode =
        ref.watch(currentHouseholdProvider).value?.taskApprovalMode;
    final requiresApprovalSubmission = isFamilyMode &&
        (currentMember?.needsSubmissionApproval(approvalMode) ?? false);
    final isOpenTask = task.assignedTo == null;
    final isAssignedToCurrentUser = task.assignedTo == currentUserId;
    final localizedTitle = localizedTaskTitle(
      AppLocalizations.of(context),
      task,
    );

    // Resolve dynamic category data
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryData = categoriesAsync.maybeWhen(
      data: (list) {
        for (final category in list) {
          if (category.id == task.category) {
            return category;
          }
        }
        return null;
      },
      orElse: () => null,
    );

    final categoryColor = categoryData != null
        ? AppColors.fromHex(categoryData.color)
        : CategoryMapping.getCategoryColor(task.category);
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
                          localizedTitle,
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
                            if (task.isRecurring || !task.isOverdue)
                              _pill(
                                icon: task.isRecurring
                                    ? Icons.event_repeat_rounded
                                    : Icons.edit_calendar_rounded,
                                label: task.isRecurring
                                    ? _recurrenceLabel(
                                        AppLocalizations.of(context),
                                        task.recurrenceType,
                                      )
                                    : AppLocalizations.of(context)
                                        .tasksPillNoDate,
                                color: task.isRecurring
                                    ? AppColors.accentGold
                                    : _unscheduledPillColor,
                                background: task.isRecurring
                                    ? AppColors.accentGold.withValues(
                                        alpha: 0.16,
                                      )
                                    : _unscheduledPillBackground,
                                borderAlpha: task.isRecurring ? 0.22 : 0.12,
                                textWeight: task.isRecurring
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                gap: task.isRecurring ? 5 : 7,
                              ),
                            if (task.isOverdue)
                              _pill(
                                icon: Icons.priority_high_rounded,
                                label: AppLocalizations.of(context)
                                    .tasksPillOverdue,
                                color: AppColors.accentRed,
                                background:
                                    AppColors.accentRed.withValues(alpha: 0.16),
                                borderAlpha: 0.26,
                              ),
                            if (isFamilyMode && task.isPendingApproval)
                              _pill(
                                icon: Icons.hourglass_top_rounded,
                                label: AppLocalizations.of(context)
                                    .tasksPillInReview,
                                color: AppColors.primary,
                                background:
                                    AppColors.primary.withValues(alpha: 0.12),
                              ),
                          ],
                        ),
                      ),
                      if (!_isExpanded && task.coinReward > 0) ...[
                        const SizedBox(width: 10),
                        _badge(
                          'Coins ${task.coinReward}',
                          AppColors.accentGreen,
                        ),
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
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                theme.divider.withValues(alpha: 0.34),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Minors (teens + children) cannot edit, schedule,
                            // or reshape tasks. Only adults manage them.
                            if (!requiresApprovalSubmission) ...[
                              Expanded(
                                child: _buildActionTilePremium(
                                  icon: Icons.edit_rounded,
                                  label:
                                      AppLocalizations.of(context).commonEdit,
                                  color: AppColors.accentGold,
                                  onTap: widget.onEdit,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildActionTilePremium(
                                  icon: Icons.schedule_rounded,
                                  label: AppLocalizations.of(context)
                                      .tasksActionSchedule,
                                  color: AppColors.primary,
                                  onTap: widget.onSchedule,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: isFamilyMode
                                  ? _buildFamilyTaskAction(
                                      isAdultView: isAdultView,
                                      requiresApprovalSubmission:
                                          requiresApprovalSubmission,
                                      isOpenTask: isOpenTask,
                                      isAssignedToCurrentUser:
                                          isAssignedToCurrentUser,
                                      assignedMember: assignedMember,
                                    )
                                  : _buildActionTilePremium(
                                      icon: Icons.check_rounded,
                                      label: _isSubmitting
                                          ? AppLocalizations.of(context)
                                              .tasksActionCompleting
                                          : AppLocalizations.of(context)
                                              .tasksActionComplete,
                                      color: AppColors.accentGreen,
                                      onTap:
                                          _isSubmitting ? null : _completeTask,
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

  Widget _buildFamilyTaskAction({
    required bool isAdultView,
    required bool requiresApprovalSubmission,
    required bool isOpenTask,
    required bool isAssignedToCurrentUser,
    required MemberModel? assignedMember,
  }) {
    final t = AppLocalizations.of(context);
    final completingLabel =
        _isSubmitting ? t.tasksActionCompleting : t.tasksActionComplete;
    if (widget.task.isPendingApproval) {
      if (!isAdultView) {
        return _buildInfoBanner(
          icon: Icons.hourglass_top_rounded,
          text: t.tasksStatusWaitingForAdult,
          color: AppColors.primary,
        );
      }

      return _buildInfoBanner(
        icon: Icons.hourglass_top_rounded,
        text: t.tasksStatusWaitingReview,
        color: AppColors.primary,
      );
    }

    if (isOpenTask) {
      return _buildActionTilePremium(
        icon: Icons.check_rounded,
        label: completingLabel,
        color: AppColors.primary,
        onTap: _isSubmitting
            ? null
            : () {
                if (requiresApprovalSubmission) {
                  _confirmOpenTaskCompletion(requiresApproval: true);
                } else {
                  _completeTask();
                }
              },
      );
    }

    if (isAssignedToCurrentUser) {
      if (requiresApprovalSubmission) {
        return _buildActionTilePremium(
          icon: Icons.send_rounded,
          label:
              _isSubmitting ? t.tasksActionSending : t.tasksActionSendForReview,
          color: AppColors.primary,
          onTap: _isSubmitting ? null : _submitTaskForApproval,
        );
      }

      return _buildActionTilePremium(
        icon: Icons.check_rounded,
        label: completingLabel,
        color: AppColors.accentGreen,
        onTap: _isSubmitting ? null : _completeTask,
      );
    }

    final ownerName =
        assignedMember?.displayName ?? t.familyTasksLockedOwnerFallback;
    if (isAdultView) {
      return _buildActionTilePremium(
        icon: Icons.check_rounded,
        label: completingLabel,
        color: AppColors.primary,
        onTap: _isSubmitting
            ? null
            : () => _confirmAdultTakeoverCompletion(ownerName),
      );
    }

    return _buildInfoBanner(
      icon: Icons.lock_outline_rounded,
      text: t.tasksStatusBelongsTo(ownerName),
      color: AppColors.textMuted,
    );
  }

  Widget _buildInfoBanner({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTilePremium({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap == null
          ? null
          : () {
              setState(() => _isExpanded = false);
              onTap();
            },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.textMuted.withValues(alpha: 0.08)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap == null
                ? AppColors.textMuted.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: onTap == null ? AppColors.textMuted : color,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: onTap == null ? AppColors.textMuted : color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOpenTaskCompletion({
    required bool requiresApproval,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final members =
        ref.read(householdMembersProvider).value ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final t = AppLocalizations.of(context);
    final actorName = currentMember?.displayName ?? t.familyTasksActorFallback;
    final localizedTitle = localizedTaskTitle(t, widget.task);

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(t.familyTasksMarkTitle),
            content: Text(
              requiresApproval
                  ? t.familyTasksMarkBodyApproval(localizedTitle, actorName)
                  : t.familyTasksMarkBodyDirect(localizedTitle, actorName),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t.commonConfirm),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    if (requiresApproval) {
      await _submitTaskForApproval();
    } else {
      await _completeTask();
    }
  }

  Future<void> _confirmAdultTakeoverCompletion(String ownerName) async {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: theme.divider.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.handshake_rounded,
                      size: 36,
                      color: AppColors.accentGold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.tasksTakeoverHeading(ownerName),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.tasksTakeoverPrompt,
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: theme.border),
                          ),
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            t.commonClose,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            t.tasksTakeoverConfirm,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;

    if (!confirmed) return;
    await _completeTask();
  }

  Future<void> _submitTaskForApproval() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(tasksProvider.notifier).submitTaskForApproval(widget.task);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: AppLocalizations.of(context).familyTasksSubmittedSnack,
        type: AppSnackBarType.info,
        duration: const Duration(milliseconds: 1500),
      );
      ref.invalidate(tasksProvider);
      ref.invalidate(todayTasksProvider);
      ref.invalidate(recentActivityProvider);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _completeTask() async {
    setState(() => _isSubmitting = true);
    try {
      final result =
          await ref.read(tasksProvider.notifier).completeTask(widget.task);
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      if (result == null) {
        AppSnackBar.show(
          context,
          message: t.tasksSnackCompleteError,
          type: AppSnackBarType.error,
        );
      } else {
        widget.onCompletedFeedback();
        AppSnackBar.show(
          context,
          message: t.tasksSnackCompleted,
          type: AppSnackBarType.success,
          duration: const Duration(milliseconds: 1500),
        );
        ref.invalidate(tasksProvider);
        ref.invalidate(todayTasksProvider);
        ref.invalidate(recentActivityProvider);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _pill({
    required IconData icon,
    required String label,
    required Color color,
    required Color background,
    double borderAlpha = 0.22,
    FontWeight textWeight = FontWeight.w800,
    double gap = 5,
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
        border: Border.all(color: color.withValues(alpha: borderAlpha)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: readableColor),
          SizedBox(width: gap),
          Text(
            label,
            style: TextStyle(
              fontWeight: textWeight,
              fontSize: 10,
              color: readableColor,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Color get _unscheduledPillColor => const Color(0xFFA8734F);

  Color get _unscheduledPillBackground => const Color(0xFFFFF7EF);

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
