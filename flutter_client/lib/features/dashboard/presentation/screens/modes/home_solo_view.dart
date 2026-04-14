import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/home_shopping_preview_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/task_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_chat_bubble.dart';

class HomeSoloView extends ConsumerStatefulWidget {
  final Future<void> Function() onRefresh;
  final String householdId;

  const HomeSoloView({
    super.key,
    required this.onRefresh,
    required this.householdId,
  });

  @override
  ConsumerState<HomeSoloView> createState() => _HomeSoloViewState();
}

class _HomeSoloViewState extends ConsumerState<HomeSoloView> {
  final Set<String> _completedTaskIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: theme.primary,
      edgeOffset: 20,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        children: [
          _buildHeader(theme),
          const SizedBox(height: AppSpacing.lg),
          _buildFinancialSummary(widget.householdId),
          const SizedBox(height: 32),
          if (caps.showTasks)
            _buildTasksSection(theme)
          else
            const HomeShoppingPreviewCard(),
          const SizedBox(height: 32),
          _buildActivitySection(theme),
          const SizedBox(height: AppSpacing.xxl + 80),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme) {
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    final members = membersAsync.whenOrNull(data: (m) => m) ?? const [];
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                _buildWelcomeGreetingSpan(
                  theme: theme,
                  currentMemberName: currentMember?.displayName,
                ),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                ),
              ).animateEntrance(),
            ),
            const SizedBox(width: AppSpacing.md),
            CustomUserAvatar(
                    name: currentMember?.displayName,
                    avatarUrl: currentMember?.avatarUrl,
                    radius: 26)
                .animateScaleIn(delay: 70),
          ],
        ),
        const SizedBox(height: 16),
        _buildHomeWelcome(theme: theme),
      ],
    );
  }

  Widget _buildHomeWelcome({required AppThemeColors theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Todo lo importante',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.55,
          ),
        ).animate().fadeIn(delay: 100.ms),
        Text(
          'de tus días',
          style: TextStyle(
            color: theme.textPrimary.withValues(alpha: 0.7),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
                width: 24,
                height: 1.5,
                color: theme.primary.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Text('Enfocate en tus objetivos hoy 🚀',
                style: TextStyle(color: theme.textSecondary, fontSize: 14)),
          ],
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  TextSpan _buildWelcomeGreetingSpan({
    required AppThemeColors theme,
    required String? currentMemberName,
  }) {
    final firstName = _firstName(currentMemberName);
    final welcome = firstName != null
        ? (_looksFeminineName(firstName) ? 'Bienvenida' : 'Bienvenido')
        : 'Bienvenido';

    return TextSpan(
      children: [
        TextSpan(
            text: '$welcome, ', style: TextStyle(color: theme.textPrimary)),
        TextSpan(
            text: firstName ?? 'Usuario',
            style:
                TextStyle(color: theme.primary, fontWeight: FontWeight.w900)),
      ],
    );
  }

  bool _looksFeminineName(String name) {
    final normalized = name.trim().toLowerCase();
    const masculineExceptions = {'blas', 'luca', 'noa', 'andrea'};
    if (masculineExceptions.contains(normalized)) return false;
    return normalized.endsWith('a');
  }

  String? _firstName(String? name) {
    if (name == null) return null;
    return name.trim().split(' ').first;
  }

  Widget _buildFinancialSummary(String householdId) {
    final balanceAsync = ref.watch(userBalanceProvider);

    return BalanceCard(
      coins: balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0,
      xp: balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0,
      userBalance: 0.0, // In solo mode we don't show internal debt
    ).animateEntrance(delay: 100);
  }

  Widget _buildTasksSection(AppThemeColors theme) {
    final tasksAsync = ref.watch(todayTasksProvider);
    final caps = ref.watch(householdCapabilitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tus tareas',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
                    letterSpacing: -0.7)),
            TextButton(
              onPressed: () {
                final index = indexForMainTab(caps, MainTab.tasks);
                if (index >= 0) {
                  ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                }
              },
              child: Text('Ver Semana',
                  style: TextStyle(
                      color: theme.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        tasksAsync.when(
          loading: () => _buildTasksShimmer(theme),
          error: (e, _) => Text('Error: $e'),
          data: (tasks) {
            if (tasks.isEmpty) {
              return _buildEmptyState('Todo listo por hoy', theme);
            }
            final myTasks = tasks.toList();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _buildTaskCard(myTasks[index], theme),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task, AppThemeColors theme) {
    return DashboardTaskCard(
      task: task,
      isCompleting: _completedTaskIds.contains(task.id),
      onTap: () => _completeTask(task),
    );
  }

  Future<void> _completeTask(TaskModel task) async {
    setState(() => _completedTaskIds.add(task.id));
    try {
      await ref.read(tasksProvider.notifier).completeTask(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _completedTaskIds.remove(task.id));
    }
  }

  Widget _buildActivitySection(AppThemeColors theme) {
    final activityAsync = ref.watch(recentActivityProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tu actividad',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.7)),
        const SizedBox(height: AppSpacing.md),
        activityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
          data: (activities) {
            if (activities.isEmpty) {
              return _buildEmptyState('No hay actividad aún', theme);
            }
            return Column(
              children: activities
                  .map((a) => ActivityChatBubble(
                        activity: a,
                        currentUserId: currentUserId,
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTasksShimmer(AppThemeColors theme) {
    return Column(
        children: List.generate(
            2,
            (_) => ShimmerLoading(
                child: Container(
                    height: 70,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(20))))));
  }

  Widget _buildEmptyState(String message, AppThemeColors theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: theme.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(children: [
        const Text('🎯', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(message,
            style: TextStyle(
                fontWeight: FontWeight.w800, color: theme.textPrimary))
      ]),
    );
  }
}
