import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/core/utils/app_scroll_physics.dart';
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
import 'package:homesync_client/shared/widgets/edge_fade.dart';
import 'package:homesync_client/shared/widgets/schedule_dialog.dart'
    show ScheduleDialog, TaskRepeatMode;
import 'package:motor/motor.dart';
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
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final ConfettiController _completionConfettiController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchOpen = false;
  bool _showTodayDoneCelebration = false;

  // Auto-centrado de los chips de filtro (patrón FilterTabs de bunpod): el
  // chip recién activado entra a la banda cómoda del viewport con un spring
  // real en vez de un ensureVisible con curva.
  static const String _allChipId = '__all__';
  final ScrollController _chipScroll = ScrollController();
  final Map<String, GlobalKey> _chipKeys = {};
  late final SingleMotionController _chipScrollMotion = SingleMotionController(
    motion: const MaterialSpringMotion.standardSpatialFast(),
    vsync: this,
  )..addListener(() {
      if (!_chipScroll.hasClients) return;
      final position = _chipScroll.position;
      _chipScroll.jumpTo(
        _chipScrollMotion.value.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    });

  GlobalKey _chipKeyFor(String? id) =>
      _chipKeys.putIfAbsent(id ?? _allChipId, GlobalKey.new);

  /// Lleva el chip a la banda cómoda (25%..75% del viewport) si quedó jammed
  /// contra un borde; si ya está en la banda, no lo mueve.
  void _scrollChipIntoView(String? id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_chipScroll.hasClients) return;
      final keyContext = _chipKeys[id ?? _allChipId]?.currentContext;
      final box = keyContext?.findRenderObject();
      if (box is! RenderBox) return;

      final position = _chipScroll.position;
      final viewport = RenderAbstractViewport.of(box);
      final current = _chipScroll.offset;
      final near = viewport.getOffsetToReveal(box, 0.25).offset;
      final far = viewport.getOffsetToReveal(box, 0.75).offset;
      final lo = far < near ? far : near;
      final hi = far < near ? near : far;
      if (current >= lo - 0.5 && current <= hi + 0.5) return;

      final target = (current < lo ? lo : hi).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _chipScrollMotion.animateTo(target, from: current);
    });
  }

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _completionConfettiController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _chipScrollMotion.dispose();
    _chipScroll.dispose();
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

  // NOTA: esta pantalla NO abre su propio canal realtime. El notifier `Tasks`
  // ya escucha la tabla `tasks` (apply local optimista + silentRefresh con
  // debounce); un segundo canal acá invalidaba el provider en cada evento y
  // causaba doble fetch pisando el update optimista.

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

    // Poda el "filtro fantasma": cuando la última tarea activa de una
    // categoría filtrada desaparece, su chip deja de renderizarse pero el
    // filtro quedaba seteado y la lista se veía vacía sin selección visible.
    ref.listen(activeCategoriesProvider, (previous, next) {
      final active = next.value;
      if (active != null) {
        ref.read(taskCategoryFilterProvider.notifier).retainOnly(active);
      }
    });

    final theme = context.theme;
    final filteredAsync = ref.watch(filteredTasksProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final selectedCategories = ref.watch(taskCategoryFilterProvider);
    final searchQuery = ref.watch(taskSearchQueryProvider).trim().toLowerCase();
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
                      data: (tasks) {
                        // La búsqueda matchea contra el título que el usuario
                        // VE (localizado vía titleKey) además del crudo de DB.
                        final locale = AppLocalizations.of(context);
                        final searched = searchQuery.isEmpty
                            ? tasks
                            : tasks
                                .where(
                                  (task) =>
                                      task.title
                                          .toLowerCase()
                                          .contains(searchQuery) ||
                                      localizedTaskTitle(locale, task)
                                          .toLowerCase()
                                          .contains(searchQuery),
                                )
                                .toList();
                        final hasFilters = selectedCategories.isNotEmpty ||
                            searchQuery.isNotEmpty;
                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(tasksProvider);
                            ref.invalidate(categoriesProvider);
                          },
                          color: AppColors.accentGold,
                          // La lista se disuelve contra los bordes en vez de
                          // cortarse seca (mismo tratamiento que Finanzas).
                          child: EdgeFade(
                            extent: 0.035,
                            child: CustomScrollView(
                              // PrimaryScrollController del tab (re-tap sube al tope).
                              primary: true,
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      8,
                                      24,
                                      10,
                                    ),
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
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
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
                                                      controller: _chipScroll,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      padding:
                                                          const EdgeInsets.only(
                                                        right: 18,
                                                      ),
                                                      itemCount:
                                                          visibleCats.length +
                                                              2,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index == 0) {
                                                          return _buildSearchChip()
                                                              .animateStaggered(
                                                            0,
                                                          );
                                                        }

                                                        if (index == 1) {
                                                          // "Todas" no es una
                                                          // categoría: usa el
                                                          // peach de acción, no
                                                          // el gris de texto
                                                          // secundario (leía
                                                          // como deshabilitado).
                                                          return _buildCategoryChip(
                                                            null,
                                                            AppLocalizations.of(
                                                              context,
                                                            ).tasksFilterAll,
                                                            theme.primary,
                                                          ).animateStaggered(1);
                                                        }

                                                        final category =
                                                            visibleCats[
                                                                index - 2];
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
                                                        ).animateStaggered(
                                                          index,
                                                        );
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
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 10,
                                                          ),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  theme.surface,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                20,
                                                              ),
                                                              border:
                                                                  Border.all(
                                                                color: theme
                                                                    .border
                                                                    .withValues(
                                                                  alpha: 0.88,
                                                                ),
                                                              ),
                                                              boxShadow: theme
                                                                  .cardShadow,
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
                                                                    .setQuery(
                                                                      val,
                                                                    );
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
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons
                                                                      .search_rounded,
                                                                  color: theme
                                                                      .textSecondary,
                                                                ),
                                                                suffixIcon: _searchController
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
                                                                  horizontal:
                                                                      16,
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
                                                theme.primary,
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
                                        MediaQuery.viewPaddingOf(context)
                                            .bottom,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildListDelegate([
                                      if (searched.isEmpty)
                                        _buildEmptyState(
                                          hasFilters ? 'filtered' : null,
                                        ),
                                      ..._buildGroupedTasks(
                                        searched,
                                        members,
                                        selectedCategories,
                                      ),
                                      // Va al final de la lista, dentro del
                                      // mismo padding inferior: como sliver
                                      // aparte quedaba un hueco muerto de
                                      // ~158px entre la última card y el botón.
                                      if (ref
                                              .read(tasksProvider.notifier)
                                              .hasMore &&
                                          searched.isNotEmpty &&
                                          !hasFilters)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            24,
                                            16,
                                            24,
                                            0,
                                          ),
                                          child: Center(
                                            child: OutlinedButton.icon(
                                              onPressed: () => ref
                                                  .read(tasksProvider.notifier)
                                                  .loadMore(),
                                              icon: const Icon(
                                                Icons.add_rounded,
                                              ),
                                              label: Text(
                                                AppLocalizations.of(context)
                                                    .tasksLoadMore,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.primary,
                                                side: const BorderSide(
                                                  color: AppColors.primary,
                                                  width: 1.5,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: AppSpacing.xl,
                                                  vertical: AppSpacing.md,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    AppRadii.xl,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
    if (!isFinalTodayTask || AppMotion.reduce(context)) {
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

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
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
                style: AppTypography.caption.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? theme.primary : theme.textPrimary,
                ),
              ),
            ],
          ),
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
    // Gramática soft unificada con el chip de búsqueda: tinte del color de la
    // categoría + texto en el color oscurecido (mismo blend que las pills de
    // las cards). El relleno sólido anterior fallaba contraste AA (blanco
    // sobre el color a 13px) y en "Todas" leía como deshabilitado.
    final readable = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.28),
      color,
    );
    final selectedBg = Color.alphaBlend(
      color.withValues(alpha: 0.14),
      theme.surface,
    );

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        key: _chipKeyFor(id),
        onTap: () {
          AppHaptics.selection();
          if (id == null) {
            ref.read(taskCategoryFilterProvider.notifier).clear();
            _scrollChipIntoView(null);
          } else {
            ref
                .read(taskCategoryFilterProvider.notifier)
                .toggle(CategoryMapping.normaliseCategory(id));
            // Solo perseguimos el chip cuando se ACTIVA (al apagarlo no hay
            // nada que mirar ahí).
            if (!isSelected) _scrollChipIntoView(id);
          }
        },
        // Patrón FilterTabs de bunpod: al seleccionarse, el chip se tiñe con
        // el color de su categoría y redondea hacia pill, sobre un spring.
        child: SingleMotionBuilder(
          motion: const MaterialSpringMotion.standardSpatialFast(),
          value: isSelected ? 1.0 : 0.0,
          builder: (context, rawT, _) {
            final t = rawT.clamp(0.0, 1.0).toDouble();
            final bg = Color.lerp(theme.surface, selectedBg, t)!;
            final borderColor =
                Color.lerp(theme.border, color.withValues(alpha: 0.45), t)!;
            final fg = Color.lerp(theme.textPrimary, readable, t)!;
            final iconColor =
                Color.lerp(color.withValues(alpha: 0.85), readable, t)!;
            final radius =
                AppRadii.md + (19 - AppRadii.md) * rawT.clamp(0.0, 1.2);

            return Container(
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(radius < 0 ? 0 : radius),
                border: Border.all(color: borderColor, width: 1.1 + 0.3 * t),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.04 + 0.06 * t),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    // El ícono de "Todas" no puede depender del label
                    // localizado (solo matcheaba el string 'todas' en es).
                    id == null
                        ? Icons.format_list_bulleted_rounded
                        : CategoryMapping.getCategoryMaterialIcon(id),
                    color: iconColor,
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
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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

    // La lista ya llega filtrada por categoría (filteredTasksProvider) y por
    // búsqueda (matcheada contra el título localizado en el build).
    final tasksToDisplay = deduped;
    final todayTasksLeft = deduped.where((task) => task.isDueToday).length;
    final canCelebrateAllDoneToday =
        selectedCategories.isEmpty && _searchController.text.trim().isEmpty;

    // 2. Group by urgency: the list answers "what do I have to deal with and
    // when", while categories stay available as filter chips above.
    final t = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrowDate = today.add(const Duration(days: 1));
    final weekEnd = today.add(const Duration(days: 7));

    final overdue = <TaskModel>[];
    final dueToday = <TaskModel>[];
    final dueTomorrow = <TaskModel>[];
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
        } else if (dueDate.isAtSameMomentAs(tomorrowDate)) {
          // Una diaria recién completada vence mañana: "Mañana" lee mucho
          // más natural que verla caer en "Esta semana".
          dueTomorrow.add(task);
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
      if (dueA == null && dueB == null) return 0;
      if (dueA == null) return 1;
      if (dueB == null) return -1;
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
        Icons.wb_twilight_rounded,
        t.tasksSectionTomorrow,
        AppColors.accentPeach,
        dueTomorrow
      ),
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
