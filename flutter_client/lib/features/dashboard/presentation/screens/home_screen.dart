import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/widgets/offline_indicator.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/modes/home_solo_view.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/modes/home_couple_view.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/modes/home_family_view.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/modes/home_friends_view.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/complete_task_sheet.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:confetti/confetti.dart';

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

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setupTaskCompletionListener(ref);
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

  void _setupTaskCompletionListener(WidgetRef ref) {
    ref.listen(todayTasksProvider, (previous, next) {
      if (previous?.asData?.value.isNotEmpty == true &&
          next.asData?.value.isEmpty == true &&
          !next.isLoading &&
          !next.hasError) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      }
    });
  }

  Widget _buildMainContent(String householdId, AppThemeColors theme) {
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
      floatingActionButton: _buildFAB(householdId, theme),
    );
  }

  Widget _buildModeDispatcher(String householdId) {
    final caps = ref.watch(householdCapabilitiesProvider);

    return switch (caps.type) {
      HouseholdType.solo => HomeSoloView(
          onRefresh: _refreshHome,
          householdId: householdId,
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

  Widget _buildFAB(String householdId, AppThemeColors theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: theme.shadowBase.withValues(alpha: 0.032),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: FloatingActionButton.extended(
            onPressed: () => _showQuickActionMenu(householdId),
            backgroundColor: theme.elevatedSurface.withValues(alpha: 0.94),
            foregroundColor: theme.primary,
            elevation: 0,
            extendedPadding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
            label: Text(
              'Nueva Acci\u00f3n',
              style: TextStyle(
                color: theme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                letterSpacing: -0.15,
              ),
            ),
            icon: Icon(Icons.add_rounded, color: theme.primary, size: 19),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: theme.primary.withValues(alpha: 0.075),
              ),
            ),
          ),
        ),
      ).animate(delay: 600.ms)
          .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1, 1),
            duration: 420.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  void _showQuickActionMenu(String householdId) {
    final theme = context.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
                    icon: Icons.receipt_long_rounded,
                    label: 'Nuevo Gasto',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      ExpenseFormSheet.show(context);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionItem(
                    icon: Icons.task_alt_rounded,
                    label: 'Nueva Tarea',
                    color: AppColors.accentBlue,
                    onTap: () {
                      Navigator.pop(context);
                      CompleteTaskSheet.show(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
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
