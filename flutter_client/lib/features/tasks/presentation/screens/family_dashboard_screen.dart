import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/tasks/domain/models/family_member_dashboard.dart';
import 'package:homesync_client/features/tasks/presentation/providers/family_member_dashboard_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Sprint 2 Modo Padres: dashboard parental.
///
/// Muestra una card por integrante del hogar con:
///  - tareas hechas vs pendientes en la ventana (semana/mes).
///  - cumplimiento (ring color).
///  - racha actual.
///  - coins ganados/gastados.
///  - top categorias del periodo.
///
/// Solo accesible para admins de hogares family con premium activo. Para
/// otros usuarios redirige al paywall (estado bloqueado), igual que la
/// PendingApprovalsScreen.
class FamilyDashboardScreen extends ConsumerStatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  ConsumerState<FamilyDashboardScreen> createState() =>
      _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends ConsumerState<FamilyDashboardScreen> {
  DashboardPeriod _period = DashboardPeriod.week;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final eligible = ref.watch(parentModeEligibleProvider);
    if (!eligible) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: Text(t.familyDashboardAppBarTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t.familyDashboardLockedNotice,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
        ),
      );
    }

    final available = ref.watch(parentModeAvailableProvider);
    if (!available) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: Text(t.familyDashboardAppBarTitle)),
        body: const _LockedHero(),
      );
    }

    final dashboardAsync = ref.watch(familyMemberDashboardProvider(_period));

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(t.familyDashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.invalidate(familyMemberDashboardProvider(_period)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<DashboardPeriod>(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary.withValues(alpha: 0.12);
                  }
                  return theme.surface;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary;
                  }
                  return theme.textSecondary;
                }),
                side: WidgetStateProperty.all(
                  BorderSide(color: theme.border.withValues(alpha: 0.7)),
                ),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              segments: [
                ButtonSegment(
                  value: DashboardPeriod.week,
                  label: Text(t.familyDashboardWeekFilter),
                ),
                const ButtonSegment(
                  value: DashboardPeriod.month,
                  label: Text('Mes'),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
          ),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No pudimos cargar el dashboard: $e',
              style: TextStyle(color: theme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (dashboard) {
          if (dashboard == null || dashboard.members.isEmpty) {
            return _EmptyState(theme: theme);
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(familyMemberDashboardProvider(_period)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _DashboardSummary(dashboard: dashboard),
                const SizedBox(height: 16),
                for (final member in dashboard.members) ...[
                  _MemberCard(
                    snapshot: member,
                    period: dashboard.period,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.snapshot, required this.period});
  final FamilyMemberSnapshot snapshot;
  final DashboardPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final plannedTotal = snapshot.plannedTotal;
    final hasTasks = plannedTotal > 0;
    final rate = hasTasks ? snapshot.completionRate : 0.0;
    final statusColor = _statusColor(snapshot, hasTasks, rate);
    final statusLabel = _statusLabel(t, snapshot, hasTasks, rate);
    final statusIcon = _statusIcon(snapshot, hasTasks, rate);
    final progressText = hasTasks
        ? '${snapshot.tasksDone}/$plannedTotal hechas'
        : period == DashboardPeriod.week
            ? t.familyDashboardEmptyWeek
            : t.familyDashboardEmptyMonth;
    final coinDelta = snapshot.coinsEarned - snapshot.coinsSpent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.border.withValues(alpha: 0.66)),
        boxShadow: [
          BoxShadow(
            color:
                theme.shadow.withValues(alpha: theme.isDarkMode ? 0.16 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomUserAvatar(
                avatarUrl: snapshot.avatarUrl,
                name: snapshot.fullName,
                userId: snapshot.userId,
                radius: 25,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.fullName,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _roleLabel(snapshot),
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasTasks) ...[
            const SizedBox(height: 13),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: rate.clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: theme.divider.withValues(alpha: 0.65),
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
          ],
          SizedBox(height: hasTasks ? 10 : 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  progressText,
                  style: TextStyle(
                    color: hasTasks ? theme.textPrimary : theme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (snapshot.streakDays > 0 || plannedTotal >= 2)
                _MiniMetric(
                  icon: Icons.local_fire_department_rounded,
                  label: snapshot.streakDays > 0
                      ? '${snapshot.streakDays} días'
                      : t.familyDashboardNoStreak,
                  color: snapshot.streakDays > 0
                      ? AppColors.accentOrange
                      : theme.textMuted,
                ),
              if (coinDelta != 0) ...[
                const SizedBox(width: 8),
                _MiniMetric(
                  icon: Icons.monetization_on_rounded,
                  color: AppColors.accentYellow,
                  label: coinDelta == 0
                      ? '0 coins'
                      : '${coinDelta > 0 ? '+' : ''}$coinDelta',
                ),
              ],
            ],
          ),
          if (snapshot.tasksOpen > 0 ||
              snapshot.tasksOverdue > 0 ||
              snapshot.tasksPendingApproval > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (snapshot.tasksOpen > 0)
                  _Stat(
                    icon: Icons.pending_actions_rounded,
                    color: AppColors.accentBlue,
                    label: '${snapshot.tasksOpen} pendientes',
                  ),
                if (snapshot.tasksOverdue > 0)
                  _Stat(
                    icon: Icons.error_outline_rounded,
                    color: AppColors.accentRed,
                    label: '${snapshot.tasksOverdue} atrasadas',
                  ),
                if (snapshot.tasksPendingApproval > 0)
                  _Stat(
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.accentGold,
                    label: '${snapshot.tasksPendingApproval} a aprobar',
                  ),
              ],
            ),
          ],
          if (snapshot.topCategories.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              period == DashboardPeriod.week
                  ? t.familyDashboardTopCategoriesWeek
                  : t.familyDashboardTopCategoriesMonth,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in snapshot.topCategories)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${c.category} · ${c.count}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(
    FamilyMemberSnapshot snapshot,
    bool hasTasks,
    double rate,
  ) {
    if (!hasTasks) return AppColors.accentBlue;
    if (snapshot.tasksOverdue > 0) return AppColors.accentRed;
    if (snapshot.tasksPendingApproval > 0) return AppColors.accentGold;
    if (rate >= 0.8) return AppColors.accentGreen;
    if (rate >= 0.5) return AppColors.accentGold;
    return AppColors.accentRed;
  }

  IconData _statusIcon(
    FamilyMemberSnapshot snapshot,
    bool hasTasks,
    double rate,
  ) {
    if (!hasTasks) return Icons.event_available_rounded;
    if (snapshot.tasksOverdue > 0) return Icons.error_outline_rounded;
    if (snapshot.tasksPendingApproval > 0) return Icons.hourglass_top_rounded;
    if (rate >= 0.8) return Icons.check_circle_rounded;
    return Icons.trending_flat_rounded;
  }

  String _statusLabel(
    AppLocalizations t,
    FamilyMemberSnapshot snapshot,
    bool hasTasks,
    double rate,
  ) {
    if (!hasTasks) return t.familyDashboardStateNoTasks;
    if (snapshot.tasksOverdue > 0) return t.familyDashboardStateAttention;
    if (snapshot.tasksPendingApproval > 0) {
      return t.familyDashboardStateToReview;
    }
    return '${(rate * 100).round()}%';
  }

  String _roleLabel(FamilyMemberSnapshot s) {
    if (s.displayRole != null && s.displayRole!.isNotEmpty) {
      return s.displayRole!;
    }
    // Note: short fallback labels — backend usually provides displayRole.
    if (s.isChild) return 'Hijo/a';
    if (s.isTeen) return 'Adolescente';
    return 'Adulto';
  }
}

class _DashboardSummary extends StatelessWidget {
  const _DashboardSummary({required this.dashboard});

  final FamilyMemberDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final members = dashboard.members;
    final done = members.fold<int>(0, (sum, m) => sum + m.tasksDone);
    final open = members.fold<int>(0, (sum, m) => sum + m.tasksOpen);
    final overdue = members.fold<int>(0, (sum, m) => sum + m.tasksOverdue);
    final approvals =
        members.fold<int>(0, (sum, m) => sum + m.tasksPendingApproval);
    final planned = done + open;
    final activeMembers = members.where((m) => m.plannedTotal > 0).length;
    final rate = planned == 0 ? null : done / planned;
    final title = dashboard.period == DashboardPeriod.week
        ? t.familyDashboardTrackingWeekly
        : t.familyDashboardTrackingMonthly;
    final subtitle = planned == 0
        ? dashboard.period == DashboardPeriod.week
            ? t.familyDashboardEmptySubtitleWeek
            : t.familyDashboardEmptySubtitleMonth
        : '$activeMembers de ${members.length} integrantes tienen tareas activas.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.border.withValues(alpha: 0.66)),
        boxShadow: [
          BoxShadow(
            color:
                theme.shadow.withValues(alpha: theme.isDarkMode ? 0.16 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (rate != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${(rate * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: t.familyDashboardLabelDone,
                  value: '$done',
                  icon: Icons.task_alt_rounded,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  label: t.familyDashboardLabelPending,
                  value: '$open',
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.accentBlue,
                ),
              ),
            ],
          ),
          if (overdue > 0 || approvals > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (overdue > 0)
                  Expanded(
                    child: _SummaryMetric(
                      label: t.familyDashboardLabelOverdue,
                      value: '$overdue',
                      icon: Icons.error_outline_rounded,
                      color: AppColors.accentRed,
                    ),
                  ),
                if (overdue > 0 && approvals > 0) const SizedBox(width: 10),
                if (approvals > 0)
                  Expanded(
                    child: _SummaryMetric(
                      label: t.familyDashboardLabelToReview,
                      value: '$approvals',
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.accentGold,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final AppThemeColors theme;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.groups_rounded,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              t.familyDashboardEmptyTitle,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.familyDashboardEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedHero extends StatelessWidget {
  const _LockedHero();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              t.familyDashboardLockedTitle,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.familyDashboardLockedBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
