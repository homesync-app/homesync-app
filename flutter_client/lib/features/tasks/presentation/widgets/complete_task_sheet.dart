import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

import '../../../household/data/repositories/supabase_household_repository.dart';
import '../../data/repositories/supabase_task_repository.dart';
import 'add_task_options_sheet.dart';
import 'task_creation_result.dart';

class CompleteTaskSheet extends ConsumerStatefulWidget {
  final VoidCallback onTasksCompleted;

  const CompleteTaskSheet({
    super.key,
    required this.onTasksCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onTasksCompleted,
  }) {
    return AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompleteTaskSheet(
        onTasksCompleted: onTasksCompleted ?? () {},
      ),
    );
  }

  @override
  ConsumerState<CompleteTaskSheet> createState() => _CompleteTaskSheetState();
}

class _CompleteTaskSheetState extends ConsumerState<CompleteTaskSheet> {
  final Set<String> _selectedTaskIds = {};
  final Set<String> _selectedMemberIds = {};
  final Set<String> _selectedCategories = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _taskItemKeys = {};

  bool _isLoading = true;
  bool _loadFailed = false;
  List<TaskModel> _allTasks = [];
  List<Map<String, dynamic>> _members = [];

  DateTime _customDate = DateTime.now();
  bool _isRightNow = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId != null) {
      _selectedMemberIds.add(currentUserId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final householdId = await ref.read(householdIdProvider.future);
      if (householdId == null) {
        throw StateError('CompleteTaskSheet requires a household');
      }

      final taskRepo = ref.read(taskRepositoryProvider);
      final result = await taskRepo.getTasks(householdId, limit: 200);
      final tasks = result.fold(
        (failure) => throw failure,
        (items) => items.where((task) => task.isActive).toList(),
      );

      final householdRepo = ref.read(householdRepositoryProvider);
      final membersResult = await householdRepo.getHouseholdMembersRaw();
      final members = membersResult.fold(
        (failure) => throw failure,
        (items) => items,
      );

      if (mounted) {
        setState(() {
          _allTasks = tasks;
          _members = members;
        });
      }
    } catch (error, stackTrace) {
      log.e(
        'CompleteTaskSheet failed to load data',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleTask(TaskModel task) {
    final taskId = task.id;
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  Future<void> _submitCompletedTasks() async {
    if (_isLoading) return;

    final t = AppLocalizations.of(context);
    if (_selectedTaskIds.isEmpty) {
      AppSnackBar.show(
        context,
        message: t.completeTaskSnackPickAtLeastOne,
        type: AppSnackBarType.warning,
      );
      return;
    }

    final currentUserId = ref.read(currentUserIdProvider);
    final canAssignCredit = ref.read(parentModeAvailableProvider);
    final effectiveSelectedMemberIds = canAssignCredit
        ? Set<String>.from(_selectedMemberIds)
        : {
            if (currentUserId != null) currentUserId,
          };

    if (effectiveSelectedMemberIds.isEmpty) {
      AppSnackBar.show(
        context,
        message: t.completeTaskSnackPickWho,
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (!_isRightNow && _customDateDay().isAfter(_today())) {
      AppSnackBar.show(
        context,
        message: t.completeTaskSnackFutureDate,
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final selectedTasks =
          _allTasks.where((t) => _selectedTaskIds.contains(t.id)).toList();

      if (selectedTasks.isEmpty ||
          selectedTasks.length != _selectedTaskIds.length) {
        throw Exception(t.completeTaskSnackTasksMissing);
      }

      int totalXp = 0;
      int totalCoins = 0;

      for (final id in _selectedTaskIds) {
        final t = selectedTasks.firstWhere((task) => task.id == id);
        totalXp += t.xpReward;
        totalCoins += t.coinReward;
      }

      final onlyMe = effectiveSelectedMemberIds.length == 1 &&
          effectiveSelectedMemberIds.contains(currentUserId);
      final approvalEnabled = ref.read(taskApprovalEnabledProvider);
      final currentMember =
          _members.where((m) => m['user_id'] == currentUserId).firstOrNull;
      final currentMemberNeedsApproval = approvalEnabled &&
          _requiresApproval(currentMember?['member_type'] as String?);

      final selectedMembersRequiringApproval = _members
          .where(
            (m) =>
                currentMemberNeedsApproval &&
                effectiveSelectedMemberIds.contains(m['user_id']) &&
                _requiresApproval(m['member_type'] as String?),
          )
          .toList();

      if (selectedMembersRequiringApproval.isNotEmpty) {
        for (final task in selectedTasks) {
          for (final member in selectedMembersRequiringApproval) {
            await ref.read(tasksProvider.notifier).submitTaskForApproval(
                  task.copyWith(
                    assignedTo: member['user_id'] as String,
                  ),
                );
          }
        }
        effectiveSelectedMemberIds.removeWhere(
          (id) =>
              selectedMembersRequiringApproval.any((m) => m['user_id'] == id),
        );
      }

      final remainingTasks =
          effectiveSelectedMemberIds.isNotEmpty ? selectedTasks : <TaskModel>[];
      final remainingMemberIds = effectiveSelectedMemberIds.toList();

      if (remainingTasks.isNotEmpty && remainingMemberIds.isNotEmpty) {
        await ref.read(tasksProvider.notifier).completeTasksBatch(
              remainingTasks,
              userIds: remainingMemberIds,
              completedAt: _isRightNow ? null : _customDate,
            );
      }

      if (mounted) {
        AppHaptics.success();
        Navigator.pop(context);

        final approvalCount = selectedMembersRequiringApproval.length;
        final directCount = remainingMemberIds.length;
        final showGamification = ref.read(householdCapabilitiesProvider).type !=
            HouseholdType.couple;

        String message;
        if (!showGamification) {
          message = t.coupleSpaceTaskCompletionMessage(selectedTasks.length);
        } else if (approvalCount > 0 && directCount > 0) {
          message = t.completeTaskMixedApprovalMessage(
            approvalCount,
            totalXp,
            totalCoins,
          );
        } else if (approvalCount > 0) {
          message = t.completeTaskApprovalOnlyMessage(approvalCount);
        } else {
          final verb = t.completeTaskRewardVerb(onlyMe ? 1 : 2);
          message = t.completeTaskRewardMessage(verb, totalXp, totalCoins);
        }

        AppSnackBar.show(
          context,
          message: message,
          type: approvalCount > 0
              ? AppSnackBarType.info
              : AppSnackBarType.success,
          duration: const Duration(milliseconds: 1900),
        );

        widget.onTasksCompleted();
      }
    } catch (error, stackTrace) {
      log.e(
        'CompleteTaskSheet failed to complete tasks',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackBar.show(
          context,
          message: AppLocalizations.of(context).tasksSnackCompleteError,
          type: AppSnackBarType.error,
        );
      }
    }
  }

  static bool _requiresApproval(String? memberType) {
    if (memberType == null) return false;
    final lower = memberType.toLowerCase();
    return lower == 'teen' || lower == 'child';
  }

  Future<void> _selectCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = context.theme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: theme.surface,
                  onSurface: theme.textPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDate = DateTime.utc(picked.year, picked.month, picked.day, 12);
        _isRightNow = false;
      });
    }
  }

  DateTime _customDateDay() {
    final local = _customDate.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _showAddTaskOptions() async {
    AppHaptics.tap();
    final existingTaskIds = _allTasks.map((task) => task.id).toSet();
    final addedTasks = <TaskCreationResult>[];
    final members = _members.map(MemberModel.fromMap).toList();
    final result = await AddTaskOptionsSheet.show(
      context,
      members,
      onTaskAdded: addedTasks.add,
    );
    if (result == true && mounted) {
      _selectedTaskIds.clear();
      await _loadData();
      if (!mounted) return;
      final addedTaskIds = _findAddedTaskIds(existingTaskIds, addedTasks);
      if (addedTaskIds.isNotEmpty) {
        setState(() => _selectedTaskIds.addAll(addedTaskIds));
        _scrollToTask(addedTaskIds.first);
      }
    }
  }

  void _scrollToTask(String taskId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final keyContext = _taskItemKeys[taskId]?.currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          alignment: 0.32,
        );
        return;
      }

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Set<String> _findAddedTaskIds(
    Set<String> previousTaskIds,
    List<TaskCreationResult> addedTasks,
  ) {
    if (addedTasks.isEmpty) return {};

    final matchedIds = <String>{};
    for (final addedTask in addedTasks) {
      final title = addedTask.title.toLowerCase().trim();
      final category = CategoryMapping.normaliseCategory(addedTask.category);

      final matches = _allTasks.where((task) {
        if (previousTaskIds.contains(task.id) || matchedIds.contains(task.id)) {
          return false;
        }
        final sameTitle = task.title.toLowerCase().trim() == title;
        final sameCategory =
            CategoryMapping.normaliseCategory(task.category) == category;
        return task.isActive && sameTitle && sameCategory;
      }).toList();

      if (matches.isNotEmpty) {
        matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        matchedIds.add(matches.first.id);
      }
    }

    return matchedIds;
  }

  @override
  Widget build(BuildContext context) {
    // Fetch categories
    final categoriesAsync = ref.watch(categoriesProvider);
    final List<CategoryModel> categories = categoriesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => [],
    );

    // Apply filters
    final filteredTasks = _allTasks.where((task) {
      final taskCatNorm = CategoryMapping.normaliseCategory(task.category);
      if (_selectedCategories.isNotEmpty &&
          !_selectedCategories.contains(taskCatNorm)) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    final tasksToShow = filteredTasks;

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: FractionallySizedBox(
              heightFactor: 0.86,
              child: _buildBody(tasksToShow, categories),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(List<TaskModel> tasks, List<CategoryModel> categories) {
    final theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: _isLoading
          ? const Center(
              child: AppLoader(),
            )
          : _loadFailed
              ? AppErrorState(
                  message: AppLocalizations.of(context).tasksLoadError,
                  onRetry: _loadData,
                )
              : Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.divider,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.task_alt_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)
                                    .completeTaskHeaderTitle,
                                style: AppTypography.heroAmount.copyWith(
                                  fontSize: 24,
                                  color: theme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)
                                  .completeTaskHeaderSubtitle,
                              style: AppTypography.caption.copyWith(
                                fontSize: 13,
                                height: 1.35,
                                color: theme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.only(
                          bottom: _selectedTaskIds.isEmpty || _isLoading
                              ? AppSpacing.xxl
                              : AppSpacing.sm,
                        ),
                        children: [
                          if (ref.watch(parentModeAvailableProvider)) ...[
                            _buildSectionHeader(
                              Icons.people_alt_rounded,
                              AppLocalizations.of(context).completeTaskWhoTitle,
                              AppLocalizations.of(context)
                                  .completeTaskWhoSubtitle,
                            ),
                            _buildMembersSelection(),
                            const SizedBox(height: 32),
                          ],
                          _buildSectionHeader(
                            Icons.schedule_rounded,
                            AppLocalizations.of(context).completeTaskWhenTitle,
                            AppLocalizations.of(context)
                                .completeTaskWhenSubtitle,
                          ),
                          _buildDateSelection(),
                          const SizedBox(height: 32),
                          _buildSectionHeader(
                            Icons.layers_rounded,
                            AppLocalizations.of(context).completeTaskTasksTitle,
                            AppLocalizations.of(context)
                                .completeTaskTasksSubtitle,
                          ),
                          _buildCategoryAndSearch(categories),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Column(
                              children: [
                                ..._buildGroupedTasksInFull(tasks, categories),
                                const SizedBox(height: AppSpacing.lg),
                                _buildAddTaskPrompt(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedTaskIds.isNotEmpty && !_isLoading)
                      Container(
                        decoration: BoxDecoration(
                          color: theme.surface.withValues(alpha: 0.98),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, -10),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(
                          24,
                          18,
                          24,
                          20 + MediaQuery.viewPaddingOf(context).bottom,
                        ),
                        child: Builder(
                          builder: (context) {
                            final canSubmit = !_isLoading &&
                                _selectedTaskIds.isNotEmpty &&
                                _selectedMemberIds.isNotEmpty;
                            // CTA héroe con press-morph M3 Expressive: el radio
                            // se contrae al presionar sobre el mismo spring del
                            // squash (patrón bunpod / _GridButton).
                            return AnimatedPress(
                              scale: 0.97,
                              haptic: AppPressHaptic.light,
                              onTap: canSubmit ? _submitCompletedTasks : null,
                              pressBuilder: (context, t, child) => Container(
                                width: double.infinity,
                                height: 58,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: theme.primary
                                      .withValues(alpha: canSubmit ? 1 : 0.45),
                                  borderRadius: BorderRadius.circular(
                                    22 + (14 - 22) * t.clamp(0.0, 1.2),
                                  ),
                                ),
                                child: child,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedTaskIds.length == 1
                                              ? 'Completar 1 tarea'
                                              : 'Completar ${_selectedTaskIds.length} tareas',
                                          style:
                                              AppTypography.cardTitle.copyWith(
                                            fontSize: 17,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSelection() {
    return SizedBox(
      height: 112,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          final user = (member['users'] as Map?)?.cast<String, dynamic>();
          final userId = member['user_id'] as String;
          final nameStr = user?['full_name'] as String? ??
              AppLocalizations.of(context).settingsHouseholdMemberFallbackName;
          final avatarUrl = user?['avatar_url'] as String?;
          final isSelected = _selectedMemberIds.contains(userId);

          return GestureDetector(
            onTap: () {
              AppHaptics.selection();
              setState(() {
                if (isSelected) {
                  _selectedMemberIds.remove(userId);
                } else {
                  _selectedMemberIds.add(userId);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              width: 72,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(isSelected ? 2.5 : 0.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.06)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        child: CustomUserAvatar(
                          name: nameStr.split(' ').first,
                          avatarUrl: avatarUrl,
                          radius: 23,
                          forceCircular: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nameStr.split(' ')[0],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateOptionCard(
              title: AppLocalizations.of(context).completeTaskTimeNow,
              icon: Icons.bolt_rounded,
              isSelected: _isRightNow,
              onTap: () => setState(() => _isRightNow = true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateOptionCard(
              title: !_isRightNow
                  ? DateFormat('d/M').format(_customDate)
                  : AppLocalizations.of(context).completeTaskTimeBefore,
              icon: Icons.calendar_today_rounded,
              isSelected: !_isRightNow,
              onTap: _selectCustomDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;
    return GestureDetector(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : theme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyStrong.copyWith(
                  color: isSelected ? Colors.white : theme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAndSearch(List<CategoryModel> categories) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: theme.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowBase.withValues(
                    alpha: theme.isDarkMode ? 0.18 : 0.02,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: AppTypography.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).completeTaskSearchHint,
                hintStyle: TextStyle(
                  color: theme.textMuted.withValues(alpha: 0.8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: theme.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 44,
          child: Builder(
            builder: (context) {
              final activeCats = _allTasks
                  .map((t) => CategoryMapping.normaliseCategory(t.category))
                  .toSet();
              final visibleCats = categories
                  .where(
                    (c) => activeCats
                        .contains(CategoryMapping.normaliseCategory(c.id)),
                  )
                  .toList();

              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  _buildCategoryChip(
                    null,
                    AppLocalizations.of(context).tasksFilterAll,
                    const Color(0xFF64748B),
                  ),
                  ...visibleCats.map(
                    (c) => _buildCategoryChip(
                      c.id,
                      localizedTaskCategoryName(
                        AppLocalizations.of(context),
                        c,
                      ),
                      AppColors.fromHex(c.color),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String? id, String name, Color color) {
    final normId = id != null ? CategoryMapping.normaliseCategory(id) : null;
    final isSelected = normId == null
        ? _selectedCategories.isEmpty
        : _selectedCategories.contains(normId);

    return GestureDetector(
      onTap: () {
        AppHaptics.tap();
        setState(() {
          if (normId == null) {
            _selectedCategories.clear();
          } else {
            if (_selectedCategories.contains(normId)) {
              _selectedCategories.remove(normId);
            } else {
              _selectedCategories.add(normId);
            }
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: isSelected ? Colors.white : color,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedTasksInFull(
    List<TaskModel> tasks,
    List<CategoryModel> categories,
  ) {
    if (tasks.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              AppLocalizations.of(context).completeTaskNoTasksAvailable,
            ),
          ),
        ),
      ];
    }

    final catLookup = <String, CategoryModel>{};
    for (final c in categories) {
      final norm = CategoryMapping.normaliseCategory(c.id);
      if (!catLookup.containsKey(norm)) catLookup[norm] = c;
    }

    final grouped = <String, List<TaskModel>>{};
    for (final t in tasks) {
      final normCat = CategoryMapping.normaliseCategory(t.category);
      (grouped[normCat] ??= []).add(t);
    }

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
            icon: '🏠',
            color: '#94A3B8',
          );

      widgets.add(
        _buildCategoryDivider(
          icon: CategoryMapping.getCategoryMaterialIcon(normCat),
          title: localizedTaskCategoryName(
            AppLocalizations.of(context),
            catInfo,
          ),
          color: AppColors.fromHex(catInfo.color),
        ),
      );

      widgets.addAll(
        catTasks.map(
          (t) => _buildTaskSelectionItem(t, AppColors.fromHex(catInfo.color)),
        ),
      );
    }

    return widgets;
  }

  Widget _buildAddTaskPrompt() {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          Text(
            t.completeTaskAddPromptTitle,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddTaskOptions,
              icon: const Icon(Icons.playlist_add_rounded, size: 20),
              label: Text(t.completeTaskAddPromptButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                textStyle: AppTypography.cardTitle.copyWith(
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDivider({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: color.withValues(alpha: 0.1), thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSelectionItem(TaskModel task, Color catColor) {
    final theme = context.theme;
    final isSelected = _selectedTaskIds.contains(task.id);
    final showGamification =
        ref.watch(householdCapabilitiesProvider).type != HouseholdType.couple;
    final itemKey = _taskItemKeys.putIfAbsent(task.id, GlobalKey.new);

    return KeyedSubtree(
      key: itemKey,
      child: GestureDetector(
        onTap: () {
          AppHaptics.tap();
          _toggleTask(task);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: isSelected ? AppColors.primary : theme.border,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? AppColors.primary : theme.textMuted,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizedTaskTitle(AppLocalizations.of(context), task),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : theme.textPrimary,
                  ),
                ),
              ),
              if (showGamification && task.xpReward > 0)
                Text(
                  '${task.xpReward} XP',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
