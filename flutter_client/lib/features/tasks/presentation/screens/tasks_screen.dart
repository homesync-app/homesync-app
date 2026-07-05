import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/core/utils/app_scroll_physics.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/screens/calendar_screen.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/add_task_options_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/edit_task_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_completion_feedback.dart';
import 'package:homesync_client/shared/widgets/app_floating_action_button.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/schedule_dialog.dart'
    show ScheduleDialog, TaskRepeatMode;
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: implementation_imports
import 'package:timeago/src/messages/es_messages.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'tasks_screen_widgets.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  RealtimeChannel? _tasksChannel;
  SupabaseClient? _realtimeClient;
  late TabController _tabController;
  late final ConfettiController _completionConfettiController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchOpen = false;
  bool _showTodayDoneCelebration = false;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', EsMessages());
    _tabController = TabController(length: 2, vsync: this);
    _completionConfettiController =
        ConfettiController(duration: const Duration(milliseconds: 1100));

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
    final channel = _tasksChannel;
    final client = _realtimeClient;
    if (channel != null && client != null) {
      // removeChannel unsubscribes AND releases the channel from the client's
      // registry; a bare unsubscribe() can leave the channel object lingering.
      // Use the cached client (not ref) because reading ref in dispose is unsafe.
      client.removeChannel(channel);
      _tasksChannel = null;
      _realtimeClient = null;
    }
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

    final client = ref.read(supabaseClientProvider);
    _realtimeClient = client;
    _tasksChannel = client
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

    AppSheet.show(
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
    final result = await AppSheet.show<bool>(
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
              // Safe-area/nav clearance is handled natively via NavClearance.
              margin: const EdgeInsets.only(bottom: 10),
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
                  physics: const AppSnappyPagePhysics(),
                  children: [
                    // TASK LIST TAB
                    filteredAsync.when(
                      // Keep the task list visible while it refreshes after a
                      // completion/create/edit instead of flashing the loader.
                      skipLoadingOnReload: true,
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
                                          horizontal: AppSpacing.xl,
                                          vertical: AppSpacing.md,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.xl,
                                          ),
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
                maxBlastForce: 2.8,
                minBlastForce: 1.0,
                numberOfParticles: 7,
                gravity: 0.18,
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 24,
            right: 24,
            child: IgnorePointer(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: child,
                  ),
                ),
                child: _showTodayDoneCelebration
                    ? _TodayDoneCelebration(
                        key: const ValueKey('today-done-celebration'),
                        message: AppLocalizations.of(context).homeAllDoneToday,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionFeedback({required bool isFinalTodayTask}) {
    final media = MediaQuery.maybeOf(context);
    if (!isFinalTodayTask || (media?.accessibleNavigation ?? false)) {
      AppHaptics.tap();
      return;
    }

    _completionConfettiController.play();
    AppHaptics.success();
    setState(() => _showTodayDoneCelebration = true);
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() => _showTodayDoneCelebration = false);
      }
    });
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
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.12)
              : theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
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
        margin: const EdgeInsets.only(right: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
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
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember = ref.watch(householdMembersProvider).maybeWhen(
          data: (members) =>
              members.where((m) => m.userId == currentUserId).firstOrNull,
          orElse: () => null,
        );
    final canCreateTasks = !(currentMember?.isChild ?? false);
    final t = AppLocalizations.of(context);
    return AppEmptyState(
      title:
          filterStatus == null ? t.tasksEmptyTitle : t.tasksEmptyFilteredTitle,
      subtitle: filterStatus == null
          ? (isSolo ? t.tasksEmptySoloSubtitle : t.tasksEmptySharedSubtitle)
          : t.tasksEmptyFilteredSubtitle,
      actionLabel:
          filterStatus == null && canCreateTasks ? t.tasksFabNew : null,
      actionIcon: Icons.add_rounded,
      onAction:
          filterStatus == null && canCreateTasks ? _showCreateTaskDialog : null,
      icon: filterStatus == null
          ? Icons.edit_note_rounded
          : Icons.filter_list_off_rounded,
      emoji: filterStatus == null ? '📝' : '🔎',
    );
  }

  List<Widget> _buildGroupedTasks(
    List<TaskModel> tasks,
    List<MemberModel> members,
    Set<String> selectedCategories,
  ) {
    // 1. Deduplicate by id (defensive: RPC may return duplicate rows).
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
    final todayTasksLeft = deduped.where((task) => task.isDueToday).length;
    final canCelebrateAllDoneToday =
        selectedCategories.isEmpty && _searchController.text.trim().isEmpty;

    // 2. Group by urgency: the list answers "what do I have to deal with and
    // when", while categories stay available as filter chips above.
    final t = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    final overdue = <TaskModel>[];
    final dueToday = <TaskModel>[];
    final thisWeek = <TaskModel>[];
    final upcoming = <TaskModel>[];
    final unscheduled = <TaskModel>[];

    for (final task in tasksToDisplay) {
      if (task.isOverdue) {
        overdue.add(task);
      } else if (task.isDueToday) {
        dueToday.add(task);
      } else {
        final dueDate = task.dueDateOnly;
        if (dueDate == null) {
          unscheduled.add(task);
        } else if (!dueDate.isAfter(weekEnd)) {
          thisWeek.add(task);
        } else {
          upcoming.add(task);
        }
      }
    }

    int byDueDate(TaskModel a, TaskModel b) {
      final dueA = a.dueDateOnly;
      final dueB = b.dueDateOnly;
      if (dueA == null || dueB == null) return 0;
      return dueA.compareTo(dueB);
    }

    overdue.sort(byDueDate);
    thisWeek.sort(byDueDate);
    upcoming.sort(byDueDate);

    final sections = <(IconData, String, Color, List<TaskModel>)>[
      (
        Icons.priority_high_rounded,
        t.tasksSectionOverdue,
        AppColors.accentRed,
        overdue
      ),
      (Icons.today_rounded, t.tasksSectionToday, AppColors.primary, dueToday),
      (
        Icons.date_range_rounded,
        t.tasksSectionThisWeek,
        AppColors.accentGold,
        thisWeek
      ),
      (
        Icons.event_rounded,
        t.tasksSectionUpcoming,
        AppColors.accentPurple,
        upcoming
      ),
      (
        Icons.edit_calendar_rounded,
        t.tasksSectionNoDate,
        AppColors.textSecondary,
        unscheduled,
      ),
    ];

    final widgets = <Widget>[];
    for (final (icon, title, color, sectionTasks) in sections) {
      if (sectionTasks.isEmpty) continue;

      widgets.add(
        _SectionHeader(
          icon: icon,
          title: title,
          count: sectionTasks.length,
          color: color,
        ).animateEntrance(),
      );

      widgets.addAll(
        sectionTasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          final isFinalTodayTask = canCelebrateAllDoneToday &&
              task.isDueToday &&
              todayTasksLeft == 1;
          return _TaskCard(
            key: ValueKey(task.id),
            task: task,
            onSchedule: () => _showScheduleDialog(task),
            onEdit: () => _showEditDialog(task),
            onCompletedFeedback: () => _showCompletionFeedback(
              isFinalTodayTask: isFinalTodayTask,
            ),
          ).animateStaggered(index);
        }),
      );
    }

    return widgets;
  }
}

// TaskModel Card moved to tasks_screen_widgets.dart
