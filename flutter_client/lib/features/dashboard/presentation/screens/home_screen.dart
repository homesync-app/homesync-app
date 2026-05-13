import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/widgets/offline_indicator.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/modes/home_couple_view.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/modes/home_family_view.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/modes/home_friends_view.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/modes/home_solo_view.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/complete_task_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_floating_action_button.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onAvatarTap;

  const HomeScreen({
    super.key,
    this.onAvatarTap,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;
  ProviderSubscription<AsyncValue<List<TaskModel>>>? _taskCompletionListener;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _taskCompletionListener = ref.listenManual(todayTasksProvider, (
      previous,
      next,
    ) {
      if (previous?.asData?.value.isNotEmpty == true &&
          next.asData?.value.isEmpty == true &&
          !next.isLoading &&
          !next.hasError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _confettiController.play();
          HapticFeedback.heavyImpact();
        });
      }
    });
  }

  @override
  void dispose() {
    _taskCompletionListener?.close();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final householdAsync = ref.watch(householdIdProvider);
    final theme = context.theme;

    return householdAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.background,
        body: const AppLoadingState(message: 'Cargando inicio...'),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: theme.background,
        body: AppErrorState(
          message: 'No pudimos cargar tu hogar.\n$e',
          onRetry: _refreshHome,
        ),
      ),
      data: (householdId) {
        if (householdId == null) {
          return Scaffold(
            backgroundColor: theme.background,
            body: const AppEmptyState(
              title: 'No perteneces a un hogar todavía',
              subtitle: 'Crea o unite a un hogar para comenzar.',
              icon: Icons.home_work_outlined,
              emoji: '🏠',
              accentColor: AppColors.accentOrange,
            ),
          );
        }
        return Stack(
          children: [
            _buildMainContent(householdId, theme),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [
                  theme.primary,
                  AppColors.success,
                  AppColors.accentOrange,
                  Colors.blue,
                  Colors.pink,
                ],
                numberOfParticles: 30,
                gravity: 0.1,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent(String householdId, AppThemeColors theme) {
    final caps = ref.watch(householdCapabilitiesProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: SafeArea(
              child: _buildModeDispatcher(householdId),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFAB(householdId, caps),
    );
  }

  Widget _buildModeDispatcher(String householdId) {
    // The capabilities provider falls back to `couple` while the current
    // household is still loading (valueOrNull == null). Without this guard
    // the user sees a ~1s flash of HomeCoupleView before flipping to the
    // correct mode. Wait until currentHouseholdProvider actually resolves —
    // unless an admin has forced a type from dev tools, in which case caps
    // are already authoritative.
    final admin = ref.watch(adminProvider);
    final householdAsync = ref.watch(currentHouseholdProvider);
    final isForcedByAdmin =
        admin.isDeveloperMode && admin.forcedHouseholdType != null;

    if (!isForcedByAdmin &&
        householdAsync.isLoading &&
        !householdAsync.hasValue) {
      return const AppLoadingState(message: 'Cargando hogar...');
    }

    final caps = ref.watch(householdCapabilitiesProvider);

    return switch (caps.type) {
      HouseholdType.solo => HomeSoloView(
          onRefresh: _refreshHome,
          householdId: householdId,
          onAvatarTap: () => widget.onAvatarTap?.call(),
        ),
      HouseholdType.family => HomeFamilyView(
          onRefresh: _refreshHome,
          householdId: householdId,
          onAvatarTap: () => widget.onAvatarTap?.call(),
        ),
      HouseholdType.friends => HomeFriendsView(
          onRefresh: _refreshHome,
          householdId: householdId,
          onAvatarTap: () => widget.onAvatarTap?.call(),
        ),
      _ => HomeCoupleView(
          onRefresh: _refreshHome,
          householdId: householdId,
          onAvatarTap: () => widget.onAvatarTap?.call(),
        ),
    };
  }

  Widget _buildFAB(
    String householdId,
    HouseholdCapabilities caps,
  ) {
    // Friends view has less vertical content; the FAB overlaps the nav bar
    // label text without this offset due to shorter bottom padding.
    final fabOffsetY = caps.type == HouseholdType.friends ? 28.0 : 0.0;

    return Transform.translate(
      offset: Offset(0, fabOffsetY),
      child: AppFloatingActionButton(
        label: caps.showTasks
            ? AppLocalizations.of(context).homeFabActions
            : AppLocalizations.of(context).homeFabExpenses,
        icon: Icons.add_rounded,
        onPressed: () => caps.showTasks
            ? _showQuickActionMenu(householdId, caps)
            : ExpenseFormSheet.show(context),
        heroTag: 'home_fab',
        margin: const EdgeInsets.only(bottom: 2),
      ),
    )
        .animate(delay: 600.ms)
        .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1, 1),
          duration: 420.ms,
          curve: Curves.easeOutBack,
        );
  }

  void _showQuickActionMenu(
    String householdId,
    HouseholdCapabilities caps,
  ) {
    final theme = context.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 32 + bottomInset),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildActionItem(
                      variant: _QuickActionVariant.expense,
                      label: AppLocalizations.of(context).homeFabExpenses,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        ExpenseFormSheet.show(context);
                      },
                    ),
                  ),
                  if (caps.showTasks) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildActionItem(
                        variant: _QuickActionVariant.task,
                        label: AppLocalizations.of(context).homeFabTasks,
                        color: AppColors.sage,
                        onTap: () {
                          Navigator.pop(context);
                          CompleteTaskSheet.show(context);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required _QuickActionVariant variant,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          height: 96,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? theme.surface : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withValues(alpha: theme.isDarkMode ? 0.2 : 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowBase.withValues(
                  alpha: theme.isDarkMode ? 0.14 : 0.045,
                ),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 21,
                        letterSpacing: -0.75,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(
                        alpha: theme.isDarkMode ? 0.16 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: color.withValues(
                        alpha: theme.isDarkMode ? 0.82 : 0.76,
                      ),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshHome() async {
    ref.invalidate(todayTasksProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(personalFinanceSummaryProvider);
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(expenseControllerProvider);
  }
}

enum _QuickActionVariant { expense, task }
